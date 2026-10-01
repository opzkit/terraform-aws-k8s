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

run "default_leaves_update_policy_unset" {
  command = plan

  assert {
    condition     = kops_cluster.k8s.update_policy == null
    error_message = "Expected update_policy to stay unset by default so existing consumers get an empty plan"
  }
}

run "external_is_passed_through" {
  command = plan

  variables {
    update_policy = "external"
  }

  assert {
    condition     = kops_cluster.k8s.update_policy == "external"
    error_message = "Expected update_policy = external on the cluster"
  }
}

run "invalid_value_is_rejected" {
  command = plan

  variables {
    update_policy = "weekly"
  }

  expect_failures = [
    var.update_policy,
  ]
}
