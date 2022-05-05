terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kops = {
      source  = "eddycharly/kops"
      version = "~>1.23.0"
    }
  }
}
