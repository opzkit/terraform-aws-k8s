terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kops = {
      source  = "eddycharly/kops"
      version = "~>1.24.0"
    }
  }
  experiments = [module_variable_optional_attrs]
}
