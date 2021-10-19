resource "aws_s3_bucket" "issuer" {
  count         = var.aws_oidc_provider ? 1 : 0
  bucket        = "${replace(var.name, ".", "-")}-irsa-issuer"
  acl           = "public-read"
  force_destroy = true
}
