mock_provider "aws" {}
mock_provider "kops" {}
mock_provider "null" {}

variables {
  name = "test-cluster"
  bucket_state_store = {
    id  = "test-bucket"
    arn = "arn:aws:s3:::test-bucket"
  }
  region             = "eu-west-1"
  vpc_id             = "vpc-123"
  dns_zone           = "test.example.com"
  kubernetes_version = "1.31.0"
  iam_role_mappings  = {}
  public_subnets = {
    a = { cidr_block = "10.0.1.0/24", id = "subnet-a" }
    b = { cidr_block = "10.0.2.0/24", id = "subnet-b" }
    c = { cidr_block = "10.0.3.0/24", id = "subnet-c" }
  }
}

run "default_empty_exclude_list" {
  command = plan

  assert {
    condition     = length(local.exclude_instance_groups) == 0
    error_message = "Expected empty exclude_instance_groups set when variable is empty"
  }
}

run "exclude_single_valid_group" {
  command = plan

  variables {
    exclude_instance_groups = ["nodes"]
  }

  assert {
    condition     = length(local.exclude_instance_groups) == 3
    error_message = "Expected 3 entries (1 group × 3 zones), got ${length(local.exclude_instance_groups)}"
  }
}

run "exclude_multiple_valid_groups" {
  command = plan

  variables {
    node_groups = {
      nodes   = {}
      workers = {}
    }
    exclude_instance_groups = ["nodes", "workers"]
  }

  assert {
    condition     = length(local.exclude_instance_groups) == 6
    error_message = "Expected 6 entries (2 groups × 3 zones), got ${length(local.exclude_instance_groups)}"
  }
}

run "exclude_subset_of_groups" {
  command = plan

  variables {
    node_groups = {
      nodes   = {}
      workers = {}
    }
    exclude_instance_groups = ["nodes"]
  }

  assert {
    condition     = length(local.exclude_instance_groups) == 3
    error_message = "Expected 3 entries (1 of 2 groups × 3 zones), got ${length(local.exclude_instance_groups)}"
  }
}

run "exclude_with_two_zones" {
  command = plan

  variables {
    public_subnets = {
      a = { cidr_block = "10.0.1.0/24", id = "subnet-a" }
      b = { cidr_block = "10.0.2.0/24", id = "subnet-b" }
    }
    control_plane = {
      size = {
        a = {}
        b = {}
      }
    }
    node_groups = {
      nodes = {
        size = {
          a = {}
          b = {}
        }
      }
    }
    exclude_instance_groups = ["nodes"]
  }

  assert {
    condition     = length(local.exclude_instance_groups) == 2
    error_message = "Expected 2 entries (1 group × 2 zones), got ${length(local.exclude_instance_groups)}"
  }
}

run "exclude_invalid_group_fails" {
  command = plan

  variables {
    exclude_instance_groups = ["nonexistent"]
  }

  expect_failures = [
    null_resource.exclude_instance_groups_check,
  ]
}
