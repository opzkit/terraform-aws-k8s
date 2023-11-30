terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kops = {
      source  = "clayrisser/kops"
      version = "1.28.0"
    }
  }
  required_version = ">= 1.3.0"
}
