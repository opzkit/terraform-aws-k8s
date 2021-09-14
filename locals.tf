locals {
  master_policies = [
    {
      Action = [
        "acm:ListCertificates",
        "acm:DescribeCertificate",
      ]
      Effect   = "Allow"
      Resource = "*"
    },
    {
      Effect : "Allow",
      Action : [
        "s3:GetObject"
      ],
      Resource : [
      "${aws_s3_bucket.state_store.arn}/addons/*"]
  }]

  iam_auth_configmap = {
    name    = "aws_iam_authenticator_config"
    version = "0.0.1"
    content = templatefile("${path.module}/iam-auth/config.yaml", {
      role_name  = replace(data.aws_caller_identity.current.arn, "/arn:aws:sts::([0-9]*):assumed-role\\/(.*)\\/.*/", "arn:aws:iam::$1:role/$2")
      cluster_id = var.name
    })
  }
  default_request_adder = {
    name    = "default_request_adder"
    version = "1.0"
    content = file("${path.module}/addons/default-request-adder.yaml")
  }
  addons = concat(var.extra_addons, [
    local.iam_auth_configmap,
  local.default_request_adder])
  addons_yaml = templatefile("${path.module}/addons/addons.yaml", {
    addons = local.addons
  })
}

data "aws_caller_identity" "current" {}
