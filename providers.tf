terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kops = {
      source  = "terraform-kops/kops"
      version = "1.28.7"
    }
  }
  required_version = ">= 1.3.0"
}
