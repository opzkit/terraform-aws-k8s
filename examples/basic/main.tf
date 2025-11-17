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
}

resource "aws_s3_bucket" "state-store" {
  bucket = "state-store"
}

resource "aws_s3_bucket_acl" "state-store" {
  bucket = aws_s3_bucket.state-store.id
  acl    = "public-read"
}
