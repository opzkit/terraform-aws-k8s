module "k8s" {
  source                  = "../../"
  iam_role_name           = "iam-role"
  name                    = "name"
  state_store_bucket_name = aws_s3_bucket.state-store.id
  region                  = "eu-west-1"
  vpc_id                  = "vpc-123"
  private_subnet_ids      = { "a" : "subnet-123" }
  public_subnet_ids       = { "a" : "subnet-987", "b" : "subnet-654" }
  admin_ssh_key           = "../dummy_ssh_private"
  dns_zone                = "test.com"
}

resource "aws_s3_bucket" "state-store" {
  bucket = "state-store"
  acl    = "public-read"
}
