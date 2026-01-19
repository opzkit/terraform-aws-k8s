locals {
  default_request_adder = [{
    name = "default_request_adder"
    # renovate: datasource=gitea-releases depName=unboundsoftware/default-request-adder registryUrl=https://gitea.unbound.se
    version = "1.6.0"
    content = templatefile("${path.module}/addons/default-request-adder.yaml", {
      excluded_namespaces = join(",", distinct(flatten([["kube-system"], local.excluded_trimmed])))
    })
  }]
  excluded_trimmed = [for ns in var.default_request_adder_excluded_namespaces : trimspace(ns)]
}
