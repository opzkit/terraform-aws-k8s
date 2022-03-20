module "k8s" {
  source             = "../../"
  name               = "name"
  bucket_state_store = aws_s3_bucket.state-store
  region             = "eu-west-1"
  vpc_id             = "vpc-123"
  private_subnet_ids = { "a" : "subnet-123" }
  public_subnet_ids  = { "a" : "subnet-987", "b" : "subnet-654" }
  admin_ssh_key      = "../dummy_ssh_private"
  dns_zone           = "test.com"
  iam_role_mappings = {
    "iam_role" : "system:masters",
    "another_role" : "system:reader"
  }
}

resource "aws_s3_bucket" "state-store" {
  bucket = "state-store"
}

resource "aws_s3_bucket_acl" "state-store" {
  bucket = aws_s3_bucket.state-store.id
  acl    = "public-read"
}

