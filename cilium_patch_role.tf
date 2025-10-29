locals {
  cilium_patch_role = [{
    name    = "cilium_patch_role"
    version = "0.0.1"
    content = file("${path.module}/addons/cilium-patch-role.yaml")
  }]
}
