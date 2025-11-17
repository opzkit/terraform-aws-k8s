data "aws_ami" "default_node_image" {
  most_recent = true
  name_regex  = "^ubuntu/.*noble-24.04-.*-server-\\d+(\\.\\d+)?$"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/*noble*"]
  }

  filter {
    name   = "architecture"
    values = [var.architecture]
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

data "aws_ami" "default_master_image" {
  most_recent = true
  name_regex  = "^ubuntu/.*noble-24.04-.*-server-\\d+(\\.\\d+)?$"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/*noble*"]
  }

  filter {
    name   = "architecture"
    values = [coalesce(var.control_plane_architecture, var.architecture)]
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
