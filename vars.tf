variable "admin_ssh_key" {
  type        = string
  description = "Path to SSH key to use for the node and master instances in the cluster"
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

variable "master_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance types for master instances"
}

variable "master_count" {
  type        = number
  default     = 1
  description = "Number of master instances"
}

variable "master_max_price" {
  type        = number
  default     = 0.03
  description = "Maximum spot price for master instances, if unset spot instances are not used"
}

variable "node_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance types for master instances"
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

variable "node_max_price" {
  type        = number
  default     = 0.03
  description = "Maximum spot price for node instances, if unset spot instances are not used"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.21.4"
  description = "Kubernetes version for kOps cluster"
}

variable "extra_addons" {
  type = list(object({
    name    = string,
    version = string,
    content = string,
  }))
  default     = []
  description = "Extra addons in the form [{name: \"<name>\", version:\"<version>\", content: \"<YAML content>\"}]"
}

variable "iam_role_name" {
  type        = string
  description = "The IAM role that will be allowed admin access to the Kubernetes cluster (format: arn:aws:iam::<account>:<role|user>/<user/role>)"
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
  description = "Enable OIDS provider for IRSA, https://kops.sigs.k8s.io/cluster_spec/#service-account-issuer-discovery-and-aws-iam-roles-for-service-accounts-irsa"
}

variable "service_account_external_permissions" {
  type        = any
  default     = []
  description = "External permissions for Service Accounts (IRSA), https://kops.sigs.k8s.io/cluster_spec/#service-account-issuer-discovery-and-aws-iam-roles-for-service-accounts-irsa"
}

variable "api_loadbalancer" {
  type        = bool
  default     = true
  description = "Should a LoadBalancer be created for the Kubernetes API"
}

variable "kubelet_auth_webhook" {
  type        = bool
  default     = false
  description = "Use webhook for Kubelet authentication"
}

variable "node_termination_handler_sqs" {
  type        = bool
  default     = false
  description = "Use SQS for Node Termination Handler draining"
}

variable "docker_config" {
  type        = string
  default     = null
  description = "Docker config containing authentication to use for accessing registries"
}

variable "container_runtime" {
  type        = string
  default     = null
  description = "Container runtime to use. If not set, kOps default will be used."
}
