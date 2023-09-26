resource "aws_s3_bucket" "issuer" {
  bucket        = "${replace(var.name, ".", "-")}-irsa-issuer"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "issuer" {
  bucket = aws_s3_bucket.issuer.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "issuer" {
  bucket                  = aws_s3_bucket.issuer.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

moved {
  from = aws_s3_bucket.issuer[0]
  to   = aws_s3_bucket.issuer
}
