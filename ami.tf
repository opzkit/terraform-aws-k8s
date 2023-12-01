data "aws_ami" "default_image" {
  most_recent = true
  name_regex  = "^ubuntu/.*focal-20.04-amd64-server-\\d+(\\.\\d+)?$"
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/*focal*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
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
