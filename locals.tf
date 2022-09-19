locals {
  master_policies_aws_loadbalancer = {
    Action = [
      "acm:ListCertificates",
      "acm:DescribeCertificate",
    ]
    Effect   = "Allow"
    Resource = "*"
  }
  master_policy_addon_bucket_access = {
    Effect : "Allow",
    Action : [
      "s3:GetObject"
    ],
    Resource : [
      "${var.bucket_state_store.arn}/${var.name}-addons/*"
    ]
  }
  master_policies = flatten([
    local.master_policies_aws_loadbalancer,
    local.master_policy_addon_bucket_access,
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

  iam_auth_configmap = {
    name    = "aws_iam_authenticator_config"
    version = "0.0.1"
    content = templatefile("${path.module}/iam-auth/config.yaml", {
      role_mappings = var.iam_role_mappings
      cluster_id    = var.name
    })
  }

  default_request_adder = {
    name    = "default_request_adder"
    version = "1.0"
    content = file("${path.module}/addons/default-request-adder.yaml")
  }

  addons = flatten([
    var.extra_addons, [
      local.iam_auth_configmap,
      local.default_request_adder
    ], var.external_cluster_autoscaler ? module.cluster_autoscaler.addons : []
  ])
  addons_yaml = templatefile("${path.module}/addons/addons.yaml.tpl", {
    addons = local.addons
  })

  private_subnets_enabled  = length(var.private_subnet_ids) > 0
  node_group_subnet_prefix = local.private_subnets_enabled ? "private-${var.region}" : "utility-${var.region}"
  topology                 = local.private_subnets_enabled ? "private" : "public"
  master_subnets_zones     = local.private_subnets_enabled ? slice(keys(var.private_subnet_ids), 0, var.master_count) : slice(keys(var.public_subnet_ids), 0, var.master_count)
}
