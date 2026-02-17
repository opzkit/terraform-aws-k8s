provider "kops" {
  state_store = "s3://state-store"
}

provider "aws" {
  s3_use_path_style = true
  region            = "eu-west-1"
}

terraform {
  required_providers {
    kops = {
      source  = "terraform-kops/kops"
      version = ">= 1.34.3"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
  required_version = ">= 1.3"
}
