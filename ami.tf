data "aws_ami" "default_node_image" {
  for_each    = merge({ "nodes" = var.architecture }, { "control_plane" = coalesce(var.control_plane_architecture, var.architecture) }, { for k, v in var.additional_nodes : k => coalesce(v.architecture, var.architecture) })
  most_recent = true
  name_regex  = "^ubuntu/.*noble-24.04-.*-server-\\d+(\\.\\d+)?$"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/*noble*"]
  }

  filter {
    name   = "architecture"
    values = [each.value]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
