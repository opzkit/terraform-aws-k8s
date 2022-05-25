resource "aws_s3_object" "extra_addons" {
  for_each = { for a in local.addons : a.name => a }
  bucket   = var.bucket_state_store.id
  key      = "${var.name}-addons/${each.value.name}/v${each.value.version}.yaml"
  content  = each.value.content
  etag     = md5(each.value.content)
  tags     = {}
  metadata = {}
}

resource "aws_s3_object" "addons" {
  bucket   = var.bucket_state_store.id
  key      = "${var.name}-addons/addon.yaml"
  content  = local.addons_yaml
  etag     = md5(local.addons_yaml)
  tags     = {}
  metadata = {}
}

resource "kops_cluster" "k8s" {
  name               = var.name
  admin_ssh_key      = var.admin_ssh_key != null ? file(var.admin_ssh_key) : null
  cloud_provider     = "aws"
  channel            = "stable"
  kubernetes_version = var.kubernetes_version
  dns_zone           = var.dns_zone
  network_id         = var.vpc_id

  networking {
    calico {}
  }

  topology {
    masters = local.topology
    nodes   = local.topology

    dns {
      type = "Public"
    }
  }

  dynamic "subnet" {
    for_each = var.private_subnet_ids
    content {
      name        = "private-${var.region}${subnet.key}"
      provider_id = subnet.value
      type        = "Private"
      zone        = "${var.region}${subnet.key}"
    }
  }

  dynamic "subnet" {
    for_each = var.public_subnet_ids
    content {
      name        = "utility-${var.region}${subnet.key}"
      provider_id = subnet.value
      type        = "Utility"
      zone        = "${var.region}${subnet.key}"
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
          instance_group   = "master-${var.region}${member.value}"
          encrypted_volume = true
        }
      }
    }
  }

  kubernetes_api_access = [
    "0.0.0.0/0"
  ]
  ssh_access = [
    "0.0.0.0/0"
  ]

  additional_policies = {
    master = length(local.master_policies) == 0 ? null : jsonencode(local.master_policies)
    node   = length(local.node_policies) == 0 ? null : jsonencode(local.node_policies)
  }

  iam {
    allow_container_registry                 = true
    use_service_account_external_permissions = var.aws_oidc_provider
    dynamic "service_account_external_permissions" {
      for_each = var.aws_oidc_provider ? local.external_permissions : []
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
    dns {}
    dynamic "load_balancer" {
      for_each = var.api_loadbalancer ? [1] : []
      content {
        type  = "Public"
        class = "Network"
      }
    }
  }

  authentication {
    aws {}
  }

  authorization {
    rbac {}
  }

  aws_load_balancer_controller {
    enabled = true
  }

  cert_manager {
    enabled = true
    managed = true
  }

  cluster_autoscaler {
    balance_similar_node_groups   = false
    enabled                       = true
    skip_nodes_with_local_storage = false
    skip_nodes_with_system_pods   = false
  }

  container_runtime = var.container_runtime

  kube_dns {
    cache_max_concurrent = 0
    cache_max_size       = 0
    provider             = "CoreDNS"
    upstream_nameservers = []
  }

  kubelet {
    authentication_token_webhook = var.kubelet_auth_webhook
    authorization_mode           = var.kubelet_auth_webhook ? "Webhook" : null
    dynamic "anonymous_auth" {
      for_each = var.kubelet_auth_webhook ? [1] : []
      content {
        value = false
      }
    }
  }

  metrics_server {
    enabled  = true
    insecure = false
  }

  node_termination_handler {
    enable_prometheus_metrics         = false
    enable_scheduled_event_draining   = false
    enable_spot_interruption_draining = false
    enabled                           = true
    enable_sqs_termination_draining   = var.node_termination_handler_sqs
    managed_asg_tag                   = var.node_termination_handler_sqs ? "aws-node-termination-handler/managed" : null
    enable_rebalance_draining         = true
    enable_rebalance_monitoring       = true
  }

  service_account_issuer_discovery {
    discovery_store          = var.aws_oidc_provider ? "s3://${aws_s3_bucket.issuer[0].bucket}" : null
    enable_aws_oidc_provider = var.aws_oidc_provider
  }

  dynamic "secrets" {
    for_each = local.secrets

    content {
      docker_config = var.docker_config
    }
  }

  addons {
    manifest = "s3://${var.bucket_state_store.id}/${var.name}-addons/addon.yaml"
  }
}

resource "kops_instance_group" "masters" {
  for_each     = toset(local.master_subnets_zones)
  cluster_name = kops_cluster.k8s.id
  name         = "master-${var.region}${each.key}"
  role         = "Master"
  min_size     = 1
  max_size     = 1
  machine_type = var.master_type
  subnets = [
    "${local.node_group_subnet_prefix}${each.key}"
  ]
  node_labels = {
    "kops.k8s.io/instancegroup" = "master-${var.region}${each.key}"
  }
  max_price = (var.master_max_price != 0 ? tostring(var.master_max_price) : null)
  depends_on = [
    kops_cluster.k8s
  ]
}

resource "kops_instance_group" "nodes" {
  for_each     = var.public_subnet_ids
  cluster_name = kops_cluster.k8s.id
  name         = "nodes-${each.key}"
  role         = "Node"
  min_size     = var.node_min_size
  max_size     = var.node_max_size
  machine_type = var.node_type
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
  max_price = (var.node_max_price != 0 ? tostring(var.node_max_price) : null)
  depends_on = [
    kops_cluster.k8s
  ]
}

resource "kops_instance_group" "additional_nodes" {
  for_each     = var.additional_nodes
  cluster_name = kops_cluster.k8s.id
  name         = "nodes-${each.key}"
  role         = "Node"
  min_size     = each.value.min_size
  max_size     = each.value.max_size
  machine_type = each.value.type
  subnets      = tolist([for k, v in var.public_subnet_ids : "${local.node_group_subnet_prefix}${k}"])
  cloud_labels = {
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/${var.name}" = "true"
  }
  node_labels = merge(each.value.labels, {
    "kops.k8s.io/instancegroup" = "nodes-${each.key}"
  })
  max_price = (each.value.max_price != 0 ? tostring(each.value.max_price) : null)
  depends_on = [
    kops_cluster.k8s
  ]
  taints                       = each.value.taints
  detailed_instance_monitoring = true
}


resource "kops_cluster_updater" "k8s_updater" {
  cluster_name = kops_cluster.k8s.id

  depends_on = [
    kops_cluster.k8s,
    kops_instance_group.masters,
    kops_instance_group.nodes,
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
