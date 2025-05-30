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

variable "architecture" {
  type        = string
  description = "The architecture to use for finding ami image for nodes"
  default     = "x86_64"
}

variable "master_architecture" {
  type        = string
  description = "The architecture to use for finding ami image for control plane"
  default     = null
}

variable "image" {
  type        = string
  description = "The image to use for instances (can be overridden by master_image, node_image and image in additional_nodes)"
  default     = null
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

variable "master_spot_allocation_strategy" {
  default     = "price-capacity-optimized"
  type        = string
  description = "The spot allocation strategy to use."
}

variable "master_count" {
  type        = number
  default     = 1
  description = "Number of master instances"
}

variable "master_max_instance_lifetime_hours" {
  type        = number
  description = "The maximum amount of time that an instance can be in service."
  default     = 168
}

variable "master_image" {
  type        = string
  description = "The image to use for master instances"
  default     = null
}

variable "node_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "Instance types for node instances. Specifying more than one instance type will result in a mixed instance policy."
}

variable "node_size" {
  default = {}
  type = map(object({
    min : optional(number, 1)
    max : optional(number, 2)
  }))
  description = "A map of node min/max sizes to use for the node groups in each zone, <zone> => <min,max>"
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

variable "node_spot_allocation_strategy" {
  default     = "price-capacity-optimized"
  type        = string
  description = "The spot allocation strategy to use."
}

variable "node_max_instance_lifetime_hours" {
  type        = number
  description = "The maximum amount of time that an instance can be in service."
  default     = 168
}

variable "node_image" {
  type        = string
  description = "The image to use for node instances"
  default     = null
}

variable "additional_nodes" {
  type = map(object({
    min_size                    = number
    max_size                    = number
    types                       = list(string)
    taints                      = list(string)
    labels                      = map(string)
    on_demand_base              = number
    on_demand_above_base        = number
    max_instance_lifetime_hours = optional(number, 168)
    spot_allocation_strategy    = optional(string, "price-capacity-optimized")
    image                       = optional(string)
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

variable "control_plane_policies" {
  type        = any
  default     = []
  description = "Additional control plane policies, https://kops.sigs.k8s.io/iam_roles/#adding-additional-policies"
}

variable "master_policies" {
  type        = any
  default     = []
  description = "Deprecated, use control_plane_policies instead."
}

variable "node_policies" {
  type        = any
  default     = []
  description = "Additional node policies, https://kops.sigs.k8s.io/iam_roles/#adding-additional-policies"
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
