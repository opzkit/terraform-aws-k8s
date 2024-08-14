locals {
  default_ingress = [{
    name    = "alb_ssl_ingress"
    version = "1.0"
    content = templatefile("${path.module}/addons/alb-ssl-ingress.yaml", {
      ssl_policy : var.alb_ssl_policy != null ? var.alb_ssl_policy : "",
      host : "alb-ssl--ingress.${var.dns_zone}"
    })
  }]
}
