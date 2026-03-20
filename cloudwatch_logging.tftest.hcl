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

run "cloudwatch_disabled_by_default" {
  command = plan

  assert {
    condition     = var.node_cloudwatch_logging.enabled == false
    error_message = "Expected CloudWatch logging to be disabled by default"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.node_bootstrap) == 0
    error_message = "Expected no log group when disabled"
  }
}

run "cloudwatch_enabled_creates_log_group" {
  command = plan

  variables {
    node_cloudwatch_logging = {
      enabled = true
    }
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.node_bootstrap) == 1
    error_message = "Expected one log group when enabled"
  }

  assert {
    condition     = aws_cloudwatch_log_group.node_bootstrap[0].name == "/k8s/node-bootstrap/test-cluster"
    error_message = "Expected log group name to be /k8s/node-bootstrap/test-cluster"
  }

  assert {
    condition     = aws_cloudwatch_log_group.node_bootstrap[0].retention_in_days == 30
    error_message = "Expected default retention of 30 days"
  }
}

run "cloudwatch_custom_log_group_and_retention" {
  command = plan

  variables {
    node_cloudwatch_logging = {
      enabled   = true
      log_group = "/custom/logs"
      retention = 7
    }
  }

  assert {
    condition     = aws_cloudwatch_log_group.node_bootstrap[0].name == "/custom/logs/test-cluster"
    error_message = "Expected custom log group name"
  }

  assert {
    condition     = aws_cloudwatch_log_group.node_bootstrap[0].retention_in_days == 7
    error_message = "Expected custom retention of 7 days"
  }
}

run "cloudwatch_default_retention_is_30" {
  command = plan

  assert {
    condition     = var.node_cloudwatch_logging.retention == 30
    error_message = "Expected default retention to be 30 days"
  }
}

run "cloudwatch_default_log_group_prefix" {
  command = plan

  assert {
    condition     = var.node_cloudwatch_logging.log_group == "/k8s/node-bootstrap"
    error_message = "Expected default log group prefix to be /k8s/node-bootstrap"
  }
}
