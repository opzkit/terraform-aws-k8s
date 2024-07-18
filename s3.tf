resource "aws_s3_bucket" "issuer" {
  #checkov:skip=CKV_AWS_18
  #checkov:skip=CKV_AWS_21
  #checkov:skip=CKV_AWS_144
  #checkov:skip=CKV_AWS_145
  #checkov:skip=CKV2_AWS_6
  #checkov:skip=CKV2_AWS_61
  #checkov:skip=CKV2_AWS_62
  bucket        = "${replace(var.name, ".", "-")}-irsa-issuer"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "issuer" {
  #checkov:skip=CKV2_AWS_65
  bucket = aws_s3_bucket.issuer.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "issuer" {
  #checkov:skip=CKV_AWS_53
  #checkov:skip=CKV_AWS_54
  #checkov:skip=CKV_AWS_55
  #checkov:skip=CKV_AWS_56
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
