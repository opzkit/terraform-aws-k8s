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
      "${data.aws_s3_bucket.state_store.arn}/${var.name}-addons/*"
    ]
  }
  master_policies = flatten([
    local.master_policies_aws_loadbalancer,
    local.master_policy_addon_bucket_access,
    var.master_policies
    ]
  )
  external_permissions_external_dns = {
    name      = "external-dns"
    namespace = "kube-system"
    aws = {
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
  external_permissions = flatten([
    local.external_permissions_external_dns,
    var.service_account_external_permissions
    ]
  )

  iam_auth_configmap = {
    name    = "aws_iam_authenticator_config"
    version = "0.0.1"
    content = templatefile("${path.module}/iam-auth/config.yaml", {
      role_name  = var.iam_role_name
      cluster_id = var.name
    })
  }

  default_request_adder = {
    name    = "default_request_adder"
    version = "1.0"
    content = file("${path.module}/addons/default-request-adder.yaml")
  }

  addons = concat(var.extra_addons, [
    local.iam_auth_configmap,
    local.default_request_adder
  ])
  addons_yaml = templatefile("${path.module}/addons/addons.yaml", {
    addons = local.addons
  })

  private_subnets_enabled  = length(var.private_subnet_ids) > 0
  node_group_subnet_prefix = local.private_subnets_enabled ? "private-${var.region}" : "utility-${var.region}"
  topology                 = local.private_subnets_enabled ? "private" : "public"
  master_subnets_zones     = local.private_subnets_enabled ? keys(var.private_subnet_ids) : slice(keys(var.public_subnet_ids), 0, var.master_count)
}

data "aws_s3_bucket" "state_store" {
  bucket = var.state_store_bucket_name
}
