locals {
  default_ingress = [{
    name    = "default_ingress"
    version = "1.0"
    content = templatefile("${path.module}/addons/default-ingress.yaml", {
      ssl_policy : var.alb_ssl_policy != null ? var.alb_ssl_policy : "",
      host : "default--ingress.${var.dns_zone}"
    })
  }]
}
