variable "admin_ssh_key" {
  type        = string
  description = "Path to SSH key to use for the node and master instances in the cluster"
}

variable "name" {
  type        = string
  description = "Name of Kubernetes cluster"
}

variable "state_store_bucket_name" {
  type        = string
  description = "Name of S3 bucket to use for kops state store. The bucket must exist!s"
}

// TODO Enable when IRSA is "working" for aws loadbalancer
//variable "irsa_bucket_name" {
//  type        = string
//  description = "Name of S3 bucket to use for kops IRSA - link?. The bucket must exist!s"
//}

variable "region" {
  type        = string
  description = "Name of AWS region to use for cluster"
}

variable "vpc_id" {
  type        = string
  description = "Id of VPC to use for cluster"
  default     = ""
}

variable "create_vpc_network" {
  type    = bool
  default = false
}

variable "private_subnet_ids" {
  type        = map(string)
  default     = {}
  description = "A map of private subnet ids to use in the form <name> => <id>"
}

variable "utility_subnet_ids" {
  type        = map(string)
  default     = {}
  description = "A map of public subnet ids to use in the form <name> => <id>"
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
  default     = null
  description = "Additional master policies, https://kops.sigs.k8s.io/iam_roles/#adding-additional-policies"
}