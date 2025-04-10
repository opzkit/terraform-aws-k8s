module "k8s" {
  source             = "../../"
  name               = "name"
  kubernetes_version = "1.31.4"
  bucket_state_store = aws_s3_bucket.state-store
  region             = "eu-west-1"
  vpc_id             = "vpc-123"
  private_subnet_ids = { "a" : "subnet-1", "b" : "subnet-2", "c" : "subnet-3" }
  public_subnet_ids  = { "a" : "subnet-4", "b" : "subnet-5", "c" : "subnet-6" }
  admin_ssh_key      = "../dummy_ssh_private"
  dns_zone           = "test.com"
  master_policies = [
    local.master_policy_some_bucket_access
  ]
  iam_role_mappings = { "iam_role" : "system:masters" }
}

resource "aws_s3_bucket" "state-store" {
  bucket = "state-store"
}

resource "aws_s3_bucket_acl" "state-store" {
  bucket = aws_s3_bucket.state-store.id
  acl    = "public-read"
}

locals {
  master_policy_some_bucket_access = {
    Effect : "Allow",
    Action : [
      "s3:GetObject"
    ],
    Resource : [
      "arn:aws:s3:::some-bucket/*"
    ]
  }
}
