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
    var.control_plane.policies,
    ]
  )
  node_policies = flatten([
    var.nodes.policies
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


  addons = flatten([
    var.extra_addons, [
      local.default_request_adder,
    ], var.external_cluster_autoscaler ? module.cluster_autoscaler.addons : [],
    length(local.allowed_cnis["cilium"]) == 1 ? local.cilium_patch_role : [],
    var.alb_ssl_policy != null ? local.default_ingress : []
  ])
  addons_yaml = templatefile("${path.module}/addons/addons.yaml.tpl", {
    addons = local.addons
  })

  private_subnets            = var.private_subnets
  public_subnets             = var.public_subnets
  private_subnets_enabled    = length(local.private_subnets) > 0
  node_group_subnet_prefix   = local.private_subnets_enabled ? "private-${var.region}" : "utility-${var.region}"
  control_plane_subnet_zones = local.private_subnets_enabled ? keys(local.private_subnets) : keys(local.public_subnets)
  nodes_subnet_zones         = local.private_subnets_enabled ? keys(local.private_subnets) : keys(local.public_subnets)
  min_number_of_nodes        = sum([for k, v in var.nodes.size : v.min])

  allowed_cnis = {
    "cilium" : var.networking_cni == "cilium" ? [1] : []
    "calico" : var.networking_cni == "calico" ? [1] : []
  }
}

resource "null_resource" "nodes_size_check" {
  lifecycle {
    precondition {
      condition     = length(setunion(setsubtract(keys(var.nodes.size), local.nodes_subnet_zones), setsubtract(local.nodes_subnet_zones, keys(var.nodes.size)))) == 0
      error_message = "The same zones must be present in both nodes.size and public/private subnets"
    }
  }
}

resource "null_resource" "control_plane_size_check" {
  lifecycle {
    precondition {
      condition     = length(setunion(setsubtract(keys(var.control_plane.size), local.control_plane_subnet_zones), setsubtract(local.control_plane_subnet_zones, keys(var.control_plane.size)))) == 0
      error_message = "The same zones must be present in both control_plane.size and public/private subnets"
    }
  }
}

resource "null_resource" "public_private_subnet_zones_check" {
  lifecycle {
    precondition {
      condition     = local.private_subnets_enabled && length(local.private_subnets) > 0 && (keys(local.private_subnets) == keys(local.public_subnets))
      error_message = "The same zones must be supplied when using private subnets"
    }
  }
}

resource "null_resource" "node_count_check" {
  lifecycle {
    precondition {
      condition     = local.min_number_of_nodes != 0
      error_message = "Number of nodes must be at least one counting all subnets"
    }
  }
}

resource "null_resource" "node_min_max_check" {
  lifecycle {
    precondition {
      condition     = alltrue(tolist([for k, v in var.nodes.size : (v.min <= v.max)]))
      error_message = "Min nodes is larger than max nodes for at least one subnet"
    }
  }
}

resource "null_resource" "cni_check" {
  lifecycle {
    precondition {
      condition     = contains(keys(local.allowed_cnis), var.networking_cni)
      error_message = "Unsupported CNI provider"
    }
  }
}
