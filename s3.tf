resource "aws_s3_bucket" "issuer" {
  bucket        = "${replace(var.name, ".", "-")}-irsa-issuer"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "issuer" {
  bucket = aws_s3_bucket.issuer.id
  acl    = "public-read"
}

moved {
  from = aws_s3_bucket.issuer[0]
  to   = aws_s3_bucket.issuer
}

moved {
  from = aws_s3_bucket_acl.issuer[0]
  to   = aws_s3_bucket_acl.issuer
}
