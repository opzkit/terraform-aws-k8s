
resource "aws_s3_bucket_object" "extra_addons" {
  for_each = { for a in local.addons : a.name => a }
  bucket   = data.aws_s3_bucket.state_store.id
  key      = "${var.name}-addons/${each.value.name}/v${each.value.version}.yaml"
  content  = each.value.content
  etag     = md5(each.value.content)
  tags     = {}
  metadata = {}
}

resource "aws_s3_bucket_object" "addons" {
  bucket   = data.aws_s3_bucket.state_store.id
  key      = "${var.name}-addons/addon.yaml"
  content  = local.addons_yaml
  etag     = md5(local.addons_yaml)
  tags     = {}
  metadata = {}
}

resource "kops_cluster" "k8s" {
  name               = var.name
  admin_ssh_key      = file(var.admin_ssh_key)
  cloud_provider     = "aws"
  channel            = "stable"
  kubernetes_version = var.kubernetes_version
  dns_zone           = var.dns_zone
  network_id         = var.vpc_id

  networking {
    calico {
      major_version = "v3"
    }
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
    "events"]
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
  "0.0.0.0/0"]
  ssh_access = [
  "0.0.0.0/0"]

  additional_policies = {
    master = jsonencode(local.master_policies)
  }

  iam {
    allow_container_registry = true
    // TODO Enable when IRSA is "working" for aws loadbalancer
    //    service_account_external_permissions {
    //      name      = "external-dns"
    //      namespace = "kube-system"
    //      aws {
    //        inline_policy = <<EOT
    //    [
    //  {
    //    "Effect": "Allow",
    //    "Action": [
    //      "route53:ChangeResourceRecordSets"
    //    ],
    //    "Resource": [
    //      "arn:aws:route53:::hostedzone/*"
    //    ]
    //  },
    //  {
    //    "Effect": "Allow",
    //    "Action": [
    //      "route53:ListHostedZones",
    //      "route53:ListResourceRecordSets"
    //    ],
    //    "Resource": [
    //      "*"
    //    ]
    //  }
    //]
    //EOT
    //      }
    //    }
  }

  api {
    load_balancer {
      type  = "Public"
      class = "Network"
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
  }

  cluster_autoscaler {
    balance_similar_node_groups   = false
    enabled                       = true
    skip_nodes_with_local_storage = false
    skip_nodes_with_system_pods   = false
  }

  kube_dns {
    cache_max_concurrent = 0
    cache_max_size       = 0
    provider             = "CoreDNS"
    replicas             = 0
    upstream_nameservers = []
  }

  kubelet {
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
  }

  // TODO Enable when IRSA is "working" for aws loadbalancer
  service_account_issuer_discovery {
    //    discovery_store          = "s3://${aws_s3_bucket.issuer.bucket}"
    enable_aws_oidc_provider = false
  }

  addons {
    manifest = "s3://${data.aws_s3_bucket.state_store.id}/${var.name}-addons/addon.yaml"
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
  "${local.node_group_subnet_prefix}${each.key}"]
  node_labels = {
    "kops.k8s.io/instancegroup" = "master-${var.region}${each.key}"
  }
  max_price = (var.master_max_price != 0 ? tostring(var.master_max_price) : null)
  depends_on = [
  kops_cluster.k8s]
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
  "${local.node_group_subnet_prefix}${each.key}"]
  cloud_labels = {
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/${var.name}" = "true"
  }
  node_labels = {
    "kops.k8s.io/instancegroup" = "nodes-${each.key}"
  }
  max_price = (var.node_max_price != 0 ? tostring(var.node_max_price) : null)
  depends_on = [
  kops_cluster.k8s]
}

resource "kops_cluster_updater" "k8s_updater" {
  cluster_name = kops_cluster.k8s.id

  depends_on = [
    kops_cluster.k8s,
    kops_instance_group.masters,
    kops_instance_group.nodes,
  ]

  keepers = merge({ cluster = kops_cluster.k8s.revision },
    tomap({ for k, v in kops_instance_group.masters : k => v.revision }),
    tomap({ for k, v in kops_instance_group.nodes : k => v.revision }),
  )

  rolling_update {
    validation_timeout = "20m"
  }

  validate {
    timeout = "20m"
  }
}
