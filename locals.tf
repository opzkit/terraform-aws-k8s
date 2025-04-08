locals {
  control_plane_policies_aws_loadbalancer = {
    Action = [
      "acm:ListCertificates",
      "acm:DescribeCertificate",
    ]
    Effect   = "Allow"
    Resource = "*"
  }
  control_plane_policy_addon_bucket_access = {
    Effect : "Allow",
    Action : [
      "s3:GetObject"
    ],
    Resource : [
      "${var.bucket_state_store.arn}/${var.name}-addons/*"
    ]
  }
  control_plane_policies = flatten([
    local.control_plane_policies_aws_loadbalancer,
    local.control_plane_policy_addon_bucket_access,
    var.control_plane_policies,
    var.master_policies
    ]
  )
  node_policies = flatten([
    var.node_policies
    ]
  )

  external_permissions = concat(var.service_account_external_permissions, var.external_cluster_autoscaler ? [
    for v in module.cluster_autoscaler.permissions : {
      name      = v.name
      namespace = v.namespace
      aws = {
        inline_policy = lookup(v.aws, "inline_policy", null)
        policy_ar_ns  = lookup(v.aws, "policy_ar_ns", tolist(null))
      }
    }
  ] : [])

  default_request_adder = {
    name    = "default_request_adder"
    version = "1.0"
    content = file("${path.module}/addons/default-request-adder.yaml")
  }

  addons = flatten([
    var.extra_addons, [
      local.default_request_adder,
    ], var.external_cluster_autoscaler ? module.cluster_autoscaler.addons : [],
    var.alb_ssl_policy != null ? local.default_ingress : []
  ])
  addons_yaml = templatefile("${path.module}/addons/addons.yaml.tpl", {
    addons = local.addons
  })

  private_subnets_enabled  = length(var.private_subnet_ids) > 0
  node_group_subnet_prefix = local.private_subnets_enabled ? "private-${var.region}" : "utility-${var.region}"
  master_subnets_zones     = local.private_subnets_enabled ? slice(keys(var.private_subnet_ids), 0, var.master_count) : slice(keys(var.public_subnet_ids), 0, var.master_count)

  min_nodes               = tomap({ for k, v in var.public_subnet_ids : k => lookup(var.node_size, k, local.min_max_node_default).min })
  max_nodes               = tomap({ for k, v in var.public_subnet_ids : k => lookup(var.node_size, k, local.min_max_node_default).max })
  min_max_node_default    = { min : 1, max : 2 }
  mox_nodes_less_than_min = anytrue(tolist([for k in keys(var.public_subnet_ids) : (local.min_nodes[k] > local.max_nodes[k])]))
  min_number_of_nodes     = sum(values(local.min_nodes))
  allowed_cnis = {
    "cilium" : var.networking_cni == "cilium" ? [1] : []
    "calico" : var.networking_cni == "calico" ? [1] : []
  }
}

resource "null_resource" "public_private_subnet_zones_check" {
  count = local.private_subnets_enabled && length(var.private_subnet_ids) > 0 && (keys(var.private_subnet_ids) != keys(var.public_subnet_ids)) ? "The same zones must be supplied when using private subnets" : 0
}

resource "null_resource" "node_count_check" {
  count = local.min_number_of_nodes == 0 ? "Number of nodes must be at least one counting all subnets" : 0
}

resource "null_resource" "node_min_max_check" {
  count = local.mox_nodes_less_than_min ? "Min nodes is larger than max nodes for at least one subnet" : 0
}

resource "null_resource" "cni_check" {
  count = !contains(keys(local.allowed_cnis), var.networking_cni) ? "Unsupported CNI provider" : 0
}
