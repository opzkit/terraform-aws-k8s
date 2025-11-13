locals {
  default_request_adder = [{
    name = "default_request_adder"
    # renovate: datasource=gitlab-releases depName=unboundsoftware/default-request-adder
    version = "1.2.2"
    content = templatefile("${path.module}/addons/default-request-adder.yaml", {
      excluded_namespaces = join(",", distinct(flatten([["kube-system"], local.excluded_trimmed])))
    })
  }]
  excluded_trimmed = [for ns in var.default_request_adder_excluded_namespaces : trimspace(ns)]
}
