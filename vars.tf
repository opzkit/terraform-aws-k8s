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

variable "private_subnet_ids" {
  type        = map(string)
  default     = {}
  description = "A map of private subnet ids to use in the form <zone> => <id>"
  validation {
    condition     = length(var.private_subnet_ids) == 0 || length(var.private_subnet_ids) % 2 == 1
    error_message = "The number of private subnets must be odd (1,3) or zero."
  }
}

variable "public_subnet_ids" {
  type        = map(string)
  default     = {}
  description = "A map of public subnet ids to use in the form <zone> => <id>"
  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnets must be provided in order for AWS ALB to work."
  }
}

variable "dns_zone" {
  type        = string
  description = "Name of DNS zone to use for cluster"
}

variable "master_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "Instance types for master instances. Specifying more than one instance type will result in a mixed instance policy."
}

variable "master_on_demand_base" {
  default     = 0
  type        = number
  description = "Number of instances in each group to keep as on demand. Specifying 0 will only use spot instances."
}

variable "master_on_demand_above_base" {
  default     = 0
  type        = number
  description = "Percentage of instances in each group above base to keep as on demand. Specifying 0 will only use spot instances."
}

variable "master_count" {
  type        = number
  default     = 1
  description = "Number of master instances"
}

variable "master_max_instance_lifetime" {
  type        = string
  description = "The maximum amount of time that an instance can be in service. Value expected must be in form of duration ('ms', 's', 'm', 'h')."
  default     = "168h"
}

variable "node_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "Instance types for master instances. Specifying more than one instance type will result in a mixed instance policy."
}

variable "node_min_size" {
  default     = 1
  type        = number
  description = "Minimum number of instances in node group"
}

variable "node_max_size" {
  default     = 2
  type        = number
  description = "Maximum number of instances in node group"
}

variable "node_on_demand_base" {
  default     = 0
  type        = number
  description = "Number of instances in each group to keep as on demand. Specifying 0 will only use spot instances."
}

variable "node_on_demand_above_base" {
  default     = 0
  type        = number
  description = "Percentage of instances in each group above base to keep as on demand. Specifying 0 will only use spot instances."
}

variable "node_max_instance_lifetime" {
  type        = string
  description = "The maximum amount of time that an instance can be in service. Value expected must be in form of duration ('ms', 's', 'm', 'h')."
  default     = "168h"
}

variable "additional_nodes" {
  type = map(object({
    min_size              = number
    max_size              = number
    types                 = list(string)
    taints                = list(string)
    labels                = map(string)
    on_demand_base        = number
    on_demand_above_base  = number
    max_instance_lifetime = optional(string, "168h")
  }))
  description = "Additional node groups"
  default     = {}
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

variable "master_policies" {
  type        = any
  default     = []
  description = "Additional master policies, https://kops.sigs.k8s.io/iam_roles/#adding-additional-policies"
}

variable "node_policies" {
  type        = any
  default     = []
  description = "Additional node policies, https://kops.sigs.k8s.io/iam_roles/#adding-additional-policies"
}

variable "aws_oidc_provider" {
  type        = bool
  default     = false
  description = "Enable OIDC provider for IRSA, https://kops.sigs.k8s.io/cluster_spec/#service-account-issuer-discovery-and-aws-iam-roles-for-service-accounts-irsa"
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

variable "node_termination_handler_sqs" {
  type        = bool
  default     = false
  description = "Use SQS for Node Termination Handler draining"
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
