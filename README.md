# terraform-k8s

Module for creating Kubernetes clusters using kOps

## What is configured

* Kubernetes cluster using [kOps](https://kops.sigs.k8s.io) with RBAC authentication enabled
* Support for [custom addons](https://kops.sigs.k8s.io/addons/#custom-addons)
* [AWS IAM Authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) is configured to allow access using AWS Iam roles

TODOs:

* IAM Auth role mapping?
* Sane defaults?
* irsa roles and policies?
* Docs
* Cleanup
* Output?

### Custom addons

## Example

  ````terraform
module "k8s" {
  source             = "opzkit/k8s/aws"
  name               = local.name
  state_store        = local.state_store
  region             = local.region
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  utility_subnet_ids = module.network.utility_subnet_ids
  admin_ssh_key      = var.kops_ssh_pub_key
  dns_zone           = aws_route53_zone.infra.name
  extra_addons = [
    {
      name : "argocd"
      version : "0.0.1"
      content : local.argocd_yaml
    }
  ]
  service_account_external_permissions = [
    local.external_permissions_external_dns
  ]

  providers = {
    kops = kops
  }
}

locals {
  external_permissions_external_dns = {
    name      = "external-dns"
    namespace = "kube-system"
    aws       = {
      inline_policy = <<EOT
              [
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
      EOT
    }
  }
}
````
