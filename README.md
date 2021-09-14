# terraform-k8s
Module for creating Kubernetes clusters using kOps

## Exampple

  ````terraform
module "k8s" {
  source             = "../../modules/k8s"
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
  }]

  providers = {
    kops = kops
  }
}

````
