resource "aws_s3_bucket" "state_store" {
  bucket        = var.state_store
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "${data.aws_caller_identity.current.id} kops state store"
  }

  lifecycle_rule {
    enabled = true
    id      = "Remove versions older than 30 days"
    noncurrent_version_expiration {
      days = 30
    }
  }

  lifecycle_rule {
    enabled = true
    id      = "Remove backups older than 60 days"
    prefix  = "${var.name}/backups"
    expiration {
      days                         = 60
      expired_object_delete_marker = false
    }
  }
}

resource "aws_s3_bucket" "issuer" {
  bucket        = "${replace(var.name, ".", "-")}-irsa-issuer"
  acl           = "public-read"
  force_destroy = true

  tags = {
    Name = "${var.name} IRSA Issuer"
  }
}

resource "aws_s3_bucket_object" "extra_addons" {
  for_each = { for a in local.addons : a.name => a }
  bucket   = aws_s3_bucket.state_store.id
  key      = "${var.name}-addons/${each.value.name}/v${each.value.version}.yaml"
  content  = each.value.content
  etag     = md5(each.value.content)
  tags     = {}
  metadata = {}
}

resource "aws_s3_bucket_object" "addons" {
  bucket   = aws_s3_bucket.state_store.id
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
    masters = "private"
    nodes   = "private"

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
    for_each = var.utility_subnet_ids
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
        for_each = var.private_subnet_ids
        content {
          name             = member.key
          instance_group   = "master-${var.region}${member.key}"
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
    service_account_external_permissions {
      name      = "external-dns"
      namespace = "kube-system"
      aws {
        inline_policy = <<EOT
    [
  {
    "Effect": "Allow",
    "Action": [
      "route53:ChangeResourceRecordSets"
    ],
    "Resource": [
      "arn:aws:route53:::hostedzone/*"
    ]
  },
  {
    "Effect": "Allow",
    "Action": [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ],
    "Resource": [
      "*"
    ]
  }
]
EOT
      }
    }
  }

  api {
    load_balancer {
      type  = "Public"
      class = "Classic"
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

  service_account_issuer_discovery {
    discovery_store          = "s3://${aws_s3_bucket.issuer.bucket}"
    enable_aws_oidc_provider = true
  }

  addons {
    manifest = "s3://${aws_s3_bucket.state_store.id}/${var.name}-addons/addon.yaml"
  }
}

resource "kops_instance_group" "masters" {
  for_each     = var.private_subnet_ids
  cluster_name = kops_cluster.k8s.id
  name         = "master-${var.region}${each.key}"
  role         = "Master"
  min_size     = 1
  max_size     = 1
  machine_type = var.master_type
  subnets = [
  "private-${var.region}${each.key}"]
  node_labels = {
    "kops.k8s.io/instancegroup" = "master-${var.region}${each.key}"
  }
  max_price = (var.master_max_price != 0 ? to_string(var.master_max_price) : null)
  depends_on = [
  kops_cluster.k8s]
}

resource "kops_instance_group" "nodes" {
  for_each     = var.private_subnet_ids
  cluster_name = kops_cluster.k8s.id
  name         = "nodes-${each.key}"
  role         = "Node"
  min_size     = 1
  max_size     = 2
  machine_type = var.node_type
  subnets = [
  "private-${var.region}${each.key}"]
  cloud_labels = {
    "k8s.io/cluster-autoscaler/enabled"     = "true"
    "k8s.io/cluster-autoscaler/${var.name}" = "true"
  }
  node_labels = {
    "kops.k8s.io/instancegroup" = "nodes-${each.key}"
  }
  max_price = (var.node_max_price != 0 ? to_string(var.node_max_price) : null)
  depends_on = [
  kops_cluster.k8s]
}

resource "kops_cluster_updater" "k8s_updater" {
  cluster_name = kops_cluster.k8s.id

  depends_on = [
    kops_cluster.k8s,
    kops_instance_group.masters["a"],
    kops_instance_group.masters["b"],
    kops_instance_group.masters["c"],
    kops_instance_group.nodes["a"],
    kops_instance_group.nodes["b"],
    kops_instance_group.nodes["c"]
  ]

  keepers = {
    cluster            = kops_cluster.k8s.revision,
    masters-eu-west-1a = kops_instance_group.masters["a"].revision,
    masters-eu-west-1b = kops_instance_group.masters["b"].revision,
    masters-eu-west-1c = kops_instance_group.masters["c"].revision,
    nodes-a            = kops_instance_group.nodes["a"].revision,
    nodes-b            = kops_instance_group.nodes["b"].revision,
    nodes-c            = kops_instance_group.nodes["c"].revision
  }

  rolling_update {
    validation_timeout = "20m"
  }

  validate {
    timeout = "20m"
  }
}
