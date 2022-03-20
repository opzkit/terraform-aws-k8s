resource "aws_s3_bucket" "issuer" {
  count         = var.aws_oidc_provider ? 1 : 0
  bucket        = "${replace(var.name, ".", "-")}-irsa-issuer"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "issuer" {
  count  = var.aws_oidc_provider ? 1 : 0
  bucket = aws_s3_bucket.issuer[count.index].id
  acl    = "public-read"
}
