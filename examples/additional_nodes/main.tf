module "k8s" {
  source             = "../../"
  name               = "name"
  kubernetes_version = "1.31.4"
  bucket_state_store = aws_s3_bucket.state-store
  region             = "eu-west-1"
  vpc_id             = "vpc-123"
  private_subnets    = { "a" : { id : "subnet-1", cidr_block : "" }, "b" : { id : "subnet-2", cidr_block : "" }, "c" : { id : "subnet-3", cidr_block : "" } }
  public_subnets     = { "a" : { id : "subnet-4", cidr_block : "" }, "b" : { id : "subnet-5", cidr_block : "" }, "c" : { id : "subnet-6", cidr_block : "" } }
  admin_ssh_key      = "../dummy_ssh_private"
  dns_zone           = "test.com"
  iam_role_mappings = {
    "iam_role" : "system:masters",
    "another_role" : "system:reader"
  }
  node_groups = {
    nodes = {}
    processing = {
      min_size             = 1
      max_size             = 2
      types                = ["c5.2xlarge", "c5a.2xlarge"]
      on_demand_base       = 0
      on_demand_above_base = 0
      taints               = ["tasks=processing:NoSchedule"]
      labels               = { "tasks" = "processing" }
    }
  }

  # Skip rolling update for the "processing" node group when updating the cluster.
  # Useful for large or stateful node groups where you want to control the rollout
  # separately. The group name must match a key in node_groups.
  exclude_instance_groups = ["processing"]
}

resource "aws_s3_bucket" "state-store" {
  bucket = "state-store"
}

resource "aws_s3_bucket_acl" "state-store" {
  bucket = aws_s3_bucket.state-store.id
  acl    = "public-read"
}
