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

  networking {
    network_id = var.vpc_id

    topology {
      dns = "Public"
    }

    dynamic "subnet" {
      for_each = var.private_subnet_ids
      content {
        name = "private-${var.region}${subnet.key}"
        id   = subnet.value
        type = "Private"
        zone = "${var.region}${subnet.key}"
      }
    }

    dynamic "subnet" {
      for_each = var.public_subnet_ids
      content {
        name = "utility-${var.region}${subnet.key}"
        id   = subnet.value
        type = "Utility"
        zone = "${var.region}${subnet.key}"
      }
    }

    dynamic "cilium" {
      for_each = local.allowed_cnis["cilium"]
      content {
        cluster_name                = var.name
        enable_remote_node_identity = true
        preallocate_bpf_maps        = true
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
        for_each = local.master_subnets_zones
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

resource "kops_instance_group" "masters" {
  for_each     = toset(local.master_subnets_zones)
  cluster_name = kops_cluster.k8s.id
  name         = "${var.control_plane_prefix}-${var.region}${each.key}"
  role         = "ControlPlane"
  image        = coalesce(var.master_image, var.image, "${data.aws_ami.default_master_image.owner_id}/${data.aws_ami.default_master_image.name}")
  min_size     = 1
  max_size     = 1
  machine_type = var.master_types[0]
  mixed_instances_policy {
    instances = var.master_types
    on_demand_base {
      value = var.master_on_demand_base
    }
    on_demand_above_base {
      value = var.master_on_demand_above_base
    }
    spot_allocation_strategy = var.master_spot_allocation_strategy
  }
  subnets = [
    "${local.node_group_subnet_prefix}${each.key}"
  ]
  node_labels = {
    "kops.k8s.io/instancegroup" = "${var.control_plane_prefix}-${var.region}${each.key}"
  }
  depends_on = [
    kops_cluster.k8s
  ]
  detailed_instance_monitoring = true
  instance_metadata {
    http_put_response_hop_limit = 3
  }
  max_instance_lifetime = var.master_max_instance_lifetime_hours != null ? "${var.master_max_instance_lifetime_hours + parseint(sha1("${var.control_plane_prefix}-${var.region}${each.key}"), 16) % 10}h0m0s" : null
}

resource "kops_instance_group" "nodes" {
  for_each     = var.public_subnet_ids
  cluster_name = kops_cluster.k8s.id
  name         = "nodes-${each.key}"
  role         = "Node"
  image        = coalesce(var.node_image, var.image, "${data.aws_ami.default_node_image.owner_id}/${data.aws_ami.default_node_image.name}")
  min_size     = local.min_nodes[each.key]
  max_size     = local.max_nodes[each.key]
  machine_type = var.node_types[0]
  mixed_instances_policy {
    instances = var.node_types
    on_demand_base {
      value = var.node_on_demand_base
    }
    on_demand_above_base {
      value = var.node_on_demand_above_base
    }
    spot_allocation_strategy = var.node_spot_allocation_strategy
  }
  subnets = [
    "${local.node_group_subnet_prefix}${each.key}"
  ]
  cloud_labels = {
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/${var.name}" = "true"
  }
  node_labels = {
    "kops.k8s.io/instancegroup" = "nodes-${each.key}"
  }
  depends_on = [
    kops_cluster.k8s
  ]
  detailed_instance_monitoring = true
  instance_metadata {
    http_put_response_hop_limit = 3
  }
  max_instance_lifetime = var.node_max_instance_lifetime_hours != null ? "${var.node_max_instance_lifetime_hours + parseint(sha1("nodes-${each.key}"), 16) % 10}h0m0s" : null
}

resource "kops_instance_group" "additional_nodes" {
  for_each     = var.additional_nodes
  cluster_name = kops_cluster.k8s.id
  name         = "nodes-${each.key}"
  role         = "Node"
  image        = coalesce(each.value.image, var.image, "${data.aws_ami.default_node_image.owner_id}/${data.aws_ami.default_node_image.name}")
  min_size     = each.value.min_size
  max_size     = each.value.max_size
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
  subnets = tolist([for k, v in var.public_subnet_ids : "${local.node_group_subnet_prefix}${k}"])
  cloud_labels = {
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/${var.name}" = "true"
  }
  node_labels = merge(each.value.labels, {
    "kops.k8s.io/instancegroup" = "nodes-${each.key}"
  })
  depends_on = [
    kops_cluster.k8s
  ]
  taints                       = each.value.taints
  detailed_instance_monitoring = true
  instance_metadata {
    http_put_response_hop_limit = 3
  }
  max_instance_lifetime = each.value.max_instance_lifetime_hours != null ? "${each.value.max_instance_lifetime_hours + parseint(sha1("nodes-${each.key}"), 16) % 10}h0m0s" : null
}

resource "kops_cluster_updater" "k8s_updater" {
  cluster_name = kops_cluster.k8s.id

  depends_on = [
    kops_cluster.k8s,
    kops_instance_group.masters,
    kops_instance_group.nodes,
    kops_instance_group.additional_nodes,
  ]

  keepers = merge({ cluster = kops_cluster.k8s.revision },
    tomap({ for k, v in kops_instance_group.masters : v.name => v.revision }),
    tomap({ for k, v in kops_instance_group.nodes : v.name => v.revision }),
    tomap({ for k, v in kops_instance_group.additional_nodes : v.name => v.revision }),
  )

  rolling_update {
    validation_timeout = "20m"
    cloud_only         = var.cloud_only
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
  # Module version v1.33.2
  source       = "git::https://github.com/opzkit/terraform-aws-k8s-addons-cluster-autoscaler.git?ref=8ec492bd68444c267a258e6db482a5856df935cf"
  replicas     = local.min_number_of_nodes > 1 ? 2 : 1
  cluster_name = var.name
}
