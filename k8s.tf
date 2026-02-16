resource "aws_s3_object" "extra_addons" {
  for_each    = { for a in local.addons : "${a.name}-${a.version}" => a }
  bucket      = var.bucket_state_store.id
  acl         = "private"
  key         = "${var.name}-addons/${each.value.name}/v${each.value.version}.yaml"
  content     = each.value.content
  source_hash = md5(each.value.content)
  tags        = {}
  metadata    = {}
}

resource "aws_s3_object" "addons" {
  bucket      = var.bucket_state_store.id
  key         = "${var.name}-addons/addon.yaml"
  content     = local.addons_yaml
  source_hash = md5(local.addons_yaml)
  tags        = {}
  metadata    = {}
}


resource "kops_cluster" "k8s" {
  lifecycle {
    precondition {
      condition     = length(local.public_subnets) >= 2
      error_message = "At least 2 public subnets must be provided in order for AWS ALB to work."
    }

  }
  containerd {
    use_ecr_credentials_for_mirrors = var.use_ecr_credentials_for_mirrors
    dynamic "registry_mirrors" {
      for_each = var.registry_mirrors
      content {
        key   = registry_mirrors.key
        value = registry_mirrors.value
      }
    }

    dynamic "config_additions" {
      for_each = var.containerd_config_additions
      content {
        key   = config_additions.key
        value = config_additions.value
      }
    }
  }
  name          = var.name
  admin_ssh_key = var.admin_ssh_key != null ? file(var.admin_ssh_key) : null
  config_store {
    base = "s3://${var.bucket_state_store.id}/${var.name}"
  }

  cloud_provider {
    aws {
      load_balancer_controller {
        enabled = true
      }

      node_termination_handler {
        enable_prometheus_metrics         = false
        enable_scheduled_event_draining   = false
        enable_spot_interruption_draining = var.node_termination_handler_sqs
        enabled                           = true
        enable_sqs_termination_draining   = var.node_termination_handler_sqs
        managed_asg_tag                   = var.node_termination_handler_sqs ? "aws-node-termination-handler/managed" : null
        enable_rebalance_draining         = var.enable_rebalance_draining
        enable_rebalance_monitoring       = var.enable_rebalance_monitoring
      }

      pod_identity_webhook {
        enabled  = true
        replicas = local.min_number_of_nodes > 1 ? 2 : 1
      }
    }
  }
  channel            = "stable"
  kubernetes_version = var.kubernetes_version
  dns_zone           = var.dns_zone
  kube_proxy {
    enabled = length(local.allowed_cnis["cilium"]) == 0
  }
  networking {
    network_id = var.vpc_id

    topology {
      dns = "Public"
    }

    dynamic "subnet" {
      for_each = local.private_subnets
      content {
        cidr = subnet.value.cidr_block
        name = "private-${var.region}${subnet.key}"
        id   = subnet.value.id
        type = "Private"
        zone = "${var.region}${subnet.key}"
      }
    }

    dynamic "subnet" {
      for_each = local.public_subnets
      content {
        cidr = subnet.value.cidr_block
        name = "utility-${var.region}${subnet.key}"
        id   = subnet.value.id
        type = "Utility"
        zone = "${var.region}${subnet.key}"
      }
    }

    dynamic "cilium" {
      for_each = local.allowed_cnis["cilium"]
      content {
        enable_remote_node_identity = true
        preallocate_bpf_maps        = true
        enable_node_port            = true
        enable_prometheus_metrics   = true
      }
    }

    dynamic "calico" {
      for_each = local.allowed_cnis["calico"]
      content {}
    }
  }

  dynamic "etcd_cluster" {
    for_each = [
      "main",
      "events"
    ]
    content {
      name = etcd_cluster.value

      dynamic "member" {
        for_each = toset([for k, v in var.control_plane.size : k if v.max > 0])
        content {
          name             = member.value
          instance_group   = "${var.control_plane_prefix}-${var.region}${member.value}"
          encrypted_volume = true
        }
      }

      manager {
        backup_retention_days = var.backup_retention
        listen_metrics_ur_ls  = []
        log_level             = 0
      }
    }
  }

  ssh_access = [
    "0.0.0.0/0"
  ]

  additional_policies = {
    control-plane = length(local.control_plane_policies) == 0 ? null : jsonencode(local.control_plane_policies)
    node          = length(local.node_policies) == 0 ? null : jsonencode(local.node_policies)
  }

  iam {
    allow_container_registry                 = true
    use_service_account_external_permissions = true
    dynamic "service_account_external_permissions" {
      for_each = local.external_permissions
      content {
        name      = service_account_external_permissions.value.name
        namespace = service_account_external_permissions.value.namespace
        aws {
          policy_ar_ns  = lookup(service_account_external_permissions.value.aws, "policy_ar_ns", null)
          inline_policy = lookup(service_account_external_permissions.value.aws, "inline_policy", null)
        }
      }
    }
  }

  api {
    public_name = "api.${var.name}"
    dns {}
    dynamic "load_balancer" {
      for_each = var.api_loadbalancer ? [1] : []
      content {
        type  = "Public"
        class = "Network"
      }
    }
    access = [
      "0.0.0.0/0"
    ]
  }

  authentication {
    aws {
      backend_mode = "CRD"
      dynamic "identity_mappings" {
        for_each = var.iam_role_mappings
        content {
          arn      = identity_mappings.key
          username = "role:{{SessionName}}}"
          groups   = [identity_mappings.value]
        }
      }
    }
  }

  authorization {
    rbac {}
  }

  cert_manager {
    enabled = true
    managed = true
  }

  dynamic "cluster_autoscaler" {
    for_each = var.external_cluster_autoscaler ? [] : [1]
    content {
      balance_similar_node_groups   = false
      enabled                       = true
      skip_nodes_with_local_storage = false
      skip_nodes_with_system_pods   = false
    }
  }

  container_runtime = var.container_runtime

  kube_dns {
    cache_max_concurrent = 0
    cache_max_size       = 0
    provider             = "CoreDNS"
    upstream_nameservers = []
  }

  kubelet {
    anonymous_auth {
      value = false
    }
  }

  metrics_server {
    enabled  = local.min_number_of_nodes > 1
    insecure = false
  }

  service_account_issuer_discovery {
    discovery_store          = "s3://${aws_s3_bucket.issuer.bucket}"
    enable_aws_oidc_provider = true
  }

  secrets {
    docker_config = var.docker_config
  }

  addons {
    manifest = "s3://${var.bucket_state_store.id}/${var.name}-addons/addon.yaml"
  }

  external_policies {
    key   = "control-plane"
    value = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  }

  external_policies {
    key   = "node"
    value = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  }

  delete {
    count = 0
  }
}

resource "kops_instance_group" "control_plane" {
  for_each     = toset([for k, v in var.control_plane.size : k if v.max > 0])
  cluster_name = kops_cluster.k8s.id
  name         = "${var.control_plane_prefix}-${var.region}${each.key}"
  role         = "ControlPlane"
  image        = coalesce(var.control_plane.image, "${data.aws_ami.default_node_image["control_plane"].owner_id}/${data.aws_ami.default_node_image["control_plane"].name}")
  min_size     = lookup(var.control_plane.size, each.key, { min = 0, max = 0 }).min
  max_size     = lookup(var.control_plane.size, each.key, { min = 0, max = 0 }).max
  machine_type = var.control_plane.types[0]
  mixed_instances_policy {
    instances = var.control_plane.types
    on_demand_base {
      value = var.control_plane.on_demand_base
    }
    on_demand_above_base {
      value = var.control_plane.on_demand_above_base
    }
    spot_allocation_strategy = var.control_plane.spot_allocation_strategy
  }
  subnets = [
    "${local.node_group_subnet_prefix}${each.key}"
  ]
  node_labels = {
    "kops.k8s.io/instancegroup"                        = "${var.control_plane_prefix}-${var.region}${each.key}"
    "node-role.kubernetes.io/${var.region}${each.key}" = true
  }
  depends_on = [
    kops_cluster.k8s
  ]
  detailed_instance_monitoring = true
  instance_metadata {
    http_put_response_hop_limit = 3
  }
  max_instance_lifetime = var.control_plane.max_instance_lifetime_hours != null ? "${var.control_plane.max_instance_lifetime_hours + parseint(sha1("${var.control_plane_prefix}-${var.region}${each.key}"), 16) % 10}h0m0s" : null
}

resource "kops_instance_group" "nodes" {
  for_each     = local.all_node_groups
  cluster_name = kops_cluster.k8s.id
  name         = each.key
  role         = "Node"
  image        = coalesce(each.value.image, "${data.aws_ami.default_node_image[each.value.name].owner_id}/${data.aws_ami.default_node_image[each.value.name].name}")
  min_size     = each.value.size.min
  max_size     = each.value.size.max
  machine_type = each.value.types[0]
  mixed_instances_policy {
    instances = each.value.types
    on_demand_base {
      value = each.value.on_demand_base
    }
    on_demand_above_base {
      value = each.value.on_demand_above_base
    }
    spot_allocation_strategy = each.value.spot_allocation_strategy
  }
  subnets = [
    "${local.node_group_subnet_prefix}${each.value.zone}"
  ]
  cloud_labels = merge({
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/${var.name}" = "true"
  }, each.value.cloud_labels)
  taints = each.value.taints
  node_labels = merge(each.value.labels, {
    "kops.k8s.io/instancegroup"                               = each.key
    "node-role.kubernetes.io/${var.region}${each.value.zone}" = true
    "node-role.kubernetes.io/${each.value.name}"              = true
  })
  depends_on = [
    kops_cluster.k8s
  ]
  detailed_instance_monitoring = true
  instance_metadata {
    http_put_response_hop_limit = 3
  }
  max_instance_lifetime = each.value.max_instance_lifetime_hours != null ? "${each.value.max_instance_lifetime_hours + parseint(sha1(each.key), 16) % 10}h0m0s" : null

  rolling_update {
    drain_and_terminate = each.value.rolling_update.drain_and_terminate
    max_surge           = each.value.rolling_update.max_surge
    max_unavailable     = each.value.rolling_update.max_unavailable
  }
}

resource "kops_cluster_updater" "k8s_updater" {
  cluster_name = kops_cluster.k8s.id

  depends_on = [
    kops_cluster.k8s,
    kops_instance_group.control_plane,
    kops_instance_group.nodes,
  ]

  keepers = merge({ cluster = kops_cluster.k8s.revision },
    tomap({ for k, v in kops_instance_group.control_plane : v.name => v.revision }),
    tomap({ for k, v in kops_instance_group.nodes : v.name => v.revision }),
  )

  rolling_update {
    validation_timeout      = "20m"
    cloud_only              = var.cloud_only
    exclude_instance_groups = local.exclude_instance_groups
  }

  validate {
    timeout = "20m"
  }
}

data "aws_security_group" "nodes" {
  depends_on = [kops_cluster_updater.k8s_updater]
  name       = "nodes.${var.name}"
}

module "cluster_autoscaler" {
  source       = "git::https://github.com/opzkit/terraform-aws-k8s-addons-cluster-autoscaler.git?ref=v1.34.3"
  replicas     = local.min_number_of_nodes > 1 ? 2 : 1
  cluster_name = var.name
}
