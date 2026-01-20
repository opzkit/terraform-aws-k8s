data "aws_ami" "default_node_image" {
  for_each    = merge({ (local.control_plane_name) = var.control_plane.architecture }, { for k, v in var.node_groups : k => v.architecture })
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
