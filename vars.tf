variable "admin_ssh_key" {
  type = string
  description = "Path to SSH key to use for the node and master instances in the cluster"
}

variable "name" {
  type = string
  description = "Name of Kubernetes cluster"
}

variable "state_store" {
  type = string
  description = "Name of S3 bucket to use for kops state store"
}

variable "region" {
  type = string
  description = "Name of AWS region to use for cluster"
}

variable "vpc_id" {
  type = string
  description = "Id of VPC to use for cluster"
}

variable "private_subnet_ids" {
  type = map(string)
  description = "A map of private subnet ids to use in the form <name> => <id>"
}

variable "utility_subnet_ids" {
  type = map(string)
  description = "A map of public subnet ids to use in the form <name> => <id>"
}

variable "dns_zone" {
  type = string
  description = "Name of DNS zone to use for cluster"
}

variable "master_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance types for master instances"
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
