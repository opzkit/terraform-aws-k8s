variable "admin_ssh_key" {
  type        = string
  description = "Path to SSH key to use for the node and master instances in the cluster"
  default     = null
}

variable "name" {
  type        = string
  description = "Name of Kubernetes cluster"
}

variable "bucket_state_store" {
  type = object({
    id  = string
    arn = string
  })
  description = "The S3 bucket to use for kops state store. The bucket must exist!"
}

variable "region" {
  type        = string
  description = "Name of AWS region to use for cluster"
}

variable "vpc_id" {
  type        = string
  description = "Id of VPC to use for cluster"
}

variable "private_subnets" {
  type = map(object({
    cidr_block = string
    id         = string
  }))
  default     = {}
  description = "A map of private subnet ids to use in the form <zone> => <id>"
}

variable "public_subnets" {
  type = map(object({
    cidr_block = string
    id         = string
  }))
  default     = {}
  description = "A map of public subnet ids to use in the form <zone> => <id>"
  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "At least 2 public subnets must be provided in order for AWS ALB to work."
  }
}

variable "dns_zone" {
  type        = string
  description = "Name of DNS zone to use for cluster"
}

variable "control_plane" {
  type = object({
    size = optional(map(object({
      min : optional(number, 1)
      max : optional(number, 2)
      })), {
      "a" = {}
      "b" = {}
      "c" = {}
    })
    architecture                = optional(string, "x86_64")
    policies                    = optional(list(any), [])
    types                       = optional(list(string), ["t3.medium"])
    taints                      = optional(list(string), [])
    on_demand_base              = optional(number, 0)
    on_demand_above_base        = optional(number, 0)
    max_instance_lifetime_hours = optional(number, 168)
    spot_allocation_strategy    = optional(string, "price-capacity-optimized")
    image                       = optional(string)
    rolling_update = optional(object({
      drain_and_terminate = optional(bool, true)
      max_surge           = optional(string, "1")
      max_unavailable     = optional(string, "1")
    }), {})
  })
  description = "Controlplane node group"
  default     = {}
}
variable "node_termination_handler_sqs" {
  type        = bool
  default     = false
  description = "Use SQS for Node Termination Handler draining"
}

variable "node_groups" {
  type = map(object({
    size = optional(map(object({
      min : optional(number, 1)
      max : optional(number, 2)
      })), {
      "a" = {}
      "b" = {}
      "c" = {}
    })
    architecture                = optional(string, "x86_64")
    policies                    = optional(list(any), [])
    types                       = optional(list(string), ["t3.medium"])
    taints                      = optional(list(string), [])
    labels                      = optional(map(string), {})
    on_demand_base              = optional(number, 0)
    on_demand_above_base        = optional(number, 0)
    max_instance_lifetime_hours = optional(number, 168)
    spot_allocation_strategy    = optional(string, "price-capacity-optimized")
    image                       = optional(string)
    rolling_update = optional(object({
      drain_and_terminate = optional(bool, true)
      max_surge           = optional(string, "1")
      max_unavailable     = optional(string, "1")
    }), {})
  }))

  description = "node groups."
  default = {
    nodes = {

    }
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for kOps cluster"
}

variable "extra_addons" {
  type = list(object({
    name               = string,
    version            = string,
    kubernetes_version = optional(string),
    content            = string,
  }))
  default     = []
  description = "Extra addons in the form [{name: \"<name>\", version:\"<version>\", content: \"<YAML content>\"}]"
}

variable "iam_role_mappings" {
  type        = map(string)
  description = "The IAM role arn that will be allowed access with a ClusterRole to the Kubernetes cluster. Mapping from IAM ARN => Kubernetes ClusterRole"
}

variable "service_account_external_permissions" {
  type = list(object({
    name      = string
    namespace = string
    aws = object({
      inline_policy = optional(string)
      policy_ar_ns  = optional(list(string))
    })
  }))
  default     = []
  description = "External permissions for Service Accounts (IRSA), https://kops.sigs.k8s.io/cluster_spec/#service-account-issuer-discovery-and-aws-iam-roles-for-service-accounts-irsa"
}

variable "api_loadbalancer" {
  type        = bool
  default     = true
  description = "Should a LoadBalancer be created for the Kubernetes API"
}

variable "enable_rebalance_draining" {
  type        = bool
  default     = false
  description = "Whether node termination handler drain nodes when the re-balance recommendation notice is received or not"
}

variable "enable_rebalance_monitoring" {
  type        = bool
  default     = false
  description = "Whether node termination handler cordon nodes when the re-balance recommendation notice is received or not"
}

variable "docker_config" {
  type        = string
  default     = "{}"
  description = "Docker config containing authentication to use for accessing registries"
}

variable "container_runtime" {
  type        = string
  default     = null
  description = "Container runtime to use. If not set, kOps default will be used."
}

variable "cloud_only" {
  type        = bool
  default     = false
  description = "CloudOnly perform rolling update without confirming progress with k8s."
}

variable "external_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "Use external cluster autoscaler and not the built in kOps addon (to support clusters with only spot instances)"
}

variable "networking_cni" {
  type        = string
  default     = "calico"
  description = "Which CNI provider to use, supported values are 'calico' and 'cilium'"
}

variable "alb_ssl_policy" {
  type        = string
  default     = null
  description = "SSL policy to use for ALB, https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/guide/ingress/annotations/#ssl-policy"
}

variable "control_plane_prefix" {
  type        = string
  default     = "control-plane"
  description = "Prefix of control plane instance groups"
}

variable "backup_retention" {
  type        = number
  default     = 90
  description = "Backup retention of etcd data in days"
}

variable "default_request_adder_excluded_namespaces" {
  type        = list(string)
  default     = []
  description = "Namespaces that should be excluded by default request adder (kube-system is always excluded), use * to disable (https://gitlab.com/unboundsoftware/default-request-adder)"
}

variable "containerd_config_additions" {
  type        = map(string)
  description = "Additional config entries for the generated container.d comfig file"
  default     = {}
}

variable "registry_mirrors" {
  type        = map(list(string))
  description = "Registry mirrors for containerd - maps registry to list of mirror endpoints"
  default     = {}
}
