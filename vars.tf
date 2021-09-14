variable "admin_ssh_key" {
  type = string
}

variable "name" {
  type = string
}

variable "state_store" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = map(string)
}

variable "utility_subnet_ids" {
  type = map(string)
}

variable "dns_zone" {
  type = string
}

variable "master_type" {
  type    = string
  default = "t3.medium"
}

variable "master_max_price" {
  type    = string
  default = "0.03"
}

variable "node_type" {
  type    = string
  default = "t3.medium"
}

variable "node_max_price" {
  type    = string
  default = "0.03"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.21.2"
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
