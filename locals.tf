locals {
  cloudwatch_hook_install = <<-EOT
    [Unit]
    Description=Install CloudWatch Agent and capture bootstrap logs
    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c '\
      set -euo pipefail; \
      TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60"); \
      REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region); \
      ARCH=$(uname -m | sed "s/x86_64/amd64/;s/aarch64/arm64/"); \
      curl -fsSL -o /tmp/amazon-cloudwatch-agent.deb \
        "https://amazoncloudwatch-agent-$REGION.s3.$REGION.amazonaws.com/ubuntu/$ARCH/latest/amazon-cloudwatch-agent.deb" && \
      dpkg -i /tmp/amazon-cloudwatch-agent.deb && \
      rm -f /tmp/amazon-cloudwatch-agent.deb && \
      journalctl -u kops-configuration -u kubelet -u containerd -u cloud-init -o short-iso --no-tail > /var/log/node-bootstrap.log && \
      /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config -m ec2 -s \
        -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json'
  EOT

  cloudwatch_hook_install_continuous = <<-EOT
    [Unit]
    Description=Install CloudWatch Agent and start log collection
    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c '\
      set -euo pipefail; \
      TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60"); \
      REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region); \
      ARCH=$(uname -m | sed "s/x86_64/amd64/;s/aarch64/arm64/"); \
      curl -fsSL -o /tmp/amazon-cloudwatch-agent.deb \
        "https://amazoncloudwatch-agent-$REGION.s3.$REGION.amazonaws.com/ubuntu/$ARCH/latest/amazon-cloudwatch-agent.deb" && \
      dpkg -i /tmp/amazon-cloudwatch-agent.deb && \
      rm -f /tmp/amazon-cloudwatch-agent.deb && \
      journalctl -u kops-configuration -u kubelet -u containerd -u cloud-init -o short-iso --no-tail > /var/log/node-bootstrap.log && \
      systemctl daemon-reload && \
      systemctl enable --now journal-to-file.service && \
      /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config -m ec2 -s \
        -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json'
  EOT
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
  node_policies = flatten([for v in var.node_groups : v.policies])

  external_permissions = concat(var.service_account_external_permissions, var.external_cluster_autoscaler ? [
    for v in module.cluster_autoscaler.permissions : {
      name      = v.name
      namespace = v.namespace
      aws = {
        inline_policy = lookup(v.aws, "inline_policy", null)
        policy_ar_ns  = lookup(v.aws, "policy_ar_ns", tolist(null))
      }
    }
    ] : [], var.external_load_balancer_controller ? [
    for v in module.aws_load_balancer_controller.permissions : {
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
    var.external_load_balancer_controller ? module.aws_load_balancer_controller.addons : [],
    length(local.allowed_cnis["cilium"]) == 1 ? local.cilium_patch_role : [],
    var.alb_ssl_policy != null ? local.default_ingress : []
  ])
  addons_yaml = templatefile("${path.module}/addons/addons.yaml.tpl", {
    addons = local.addons
  })

  private_subnets          = var.private_subnets
  public_subnets           = var.public_subnets
  private_subnets_enabled  = length(local.private_subnets) > 0
  node_group_subnet_prefix = local.private_subnets_enabled ? "private-${var.region}" : "utility-${var.region}"
  subnet_zones             = local.private_subnets_enabled ? keys(local.private_subnets) : keys(local.public_subnets)
  min_number_of_nodes      = sum([for v in var.node_groups : sum([for x in v.size : x.min])])

  allowed_cnis = {
    "cilium" : var.networking_cni == "cilium" ? [1] : []
    "calico" : var.networking_cni == "calico" ? [1] : []
  }

  control_plane_name = "control_plane"

  all_node_group_in_subnets = setproduct(keys(var.node_groups), keys(local.public_subnets))

  all_node_groups = { for k in local.all_node_group_in_subnets : "${k[0]}-${k[1]}" =>
    {
      name                        = k[0]
      zone                        = k[1]
      size                        = var.node_groups[k[0]].size[k[1]]
      policies                    = var.node_groups[k[0]].policies
      types                       = var.node_groups[k[0]].types
      taints                      = var.node_groups[k[0]].taints
      labels                      = var.node_groups[k[0]].labels
      cloud_labels                = var.node_groups[k[0]].cloud_labels
      on_demand_base              = var.node_groups[k[0]].on_demand_base
      on_demand_above_base        = var.node_groups[k[0]].on_demand_above_base
      max_instance_lifetime_hours = var.node_groups[k[0]].max_instance_lifetime_hours
      spot_allocation_strategy    = var.node_groups[k[0]].spot_allocation_strategy
      cpu_credits                 = var.node_groups[k[0]].cpu_credits
      image                       = var.node_groups[k[0]].image
      rolling_update              = var.node_groups[k[0]].rolling_update
      architecture                = var.node_groups[k[0]].architecture
    }
  }
  exclude_instance_groups = toset([for k in setproduct(var.exclude_instance_groups, keys(local.public_subnets)) : "${k[0]}-${k[1]}"])
}

resource "null_resource" "exclude_instance_groups_check" {
  lifecycle {
    precondition {
      condition     = alltrue([for item in var.exclude_instance_groups : contains(keys(var.node_groups), item)])
      error_message = "Exclusion group must be part of node_groups"
    }
  }
}

resource "null_resource" "nodes_subnet_check" {
  for_each = var.node_groups
  lifecycle {
    precondition {
      condition     = length(setunion(setsubtract(keys(each.value.size), local.subnet_zones), setsubtract(local.subnet_zones, keys(each.value.size)))) == 0
      error_message = "Node group '${each.key}' has zones: ${join(", ", keys(each.value.size))}, but required zones are ${join(", ", local.subnet_zones)}"
    }
  }
}

resource "null_resource" "control_plane_size_check" {
  lifecycle {
    precondition {
      condition     = length(setunion(setsubtract(keys(var.control_plane.size), local.subnet_zones), setsubtract(local.subnet_zones, keys(var.control_plane.size)))) == 0
      error_message = "Controlplane has zones: ${join(", ", keys(var.control_plane.size))}, but required zones are ${join(", ", local.subnet_zones)}"
    }
  }
}

resource "null_resource" "public_private_subnet_zones_check" {
  lifecycle {
    precondition {
      condition     = !local.private_subnets_enabled || (length(local.private_subnets) > 0 && (keys(local.private_subnets) == keys(local.public_subnets)))
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

resource "null_resource" "control_plane_count_check" {
  lifecycle {
    precondition {
      condition     = sum([for k, v in var.control_plane.size : v.min]) != 0
      error_message = "Number of control plane nodes must be at least one counting all subnets"
    }
  }
}

resource "null_resource" "node_min_max_check" {
  for_each = local.all_node_groups
  lifecycle {
    precondition {
      condition     = each.value.size.min <= each.value.size.max
      error_message = "Min nodes is larger than max nodes for node-group '${each.value.name}' and zone '${each.value.zone}'"
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

resource "null_resource" "hubble_requires_cilium" {
  lifecycle {
    precondition {
      condition     = !var.cilium_hubble.enabled || var.networking_cni == "cilium"
      error_message = "Hubble requires networking_cni to be 'cilium'."
    }
  }
}
