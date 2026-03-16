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

run "hubble_disabled_by_default" {
  command = plan

  variables {
    networking_cni = "cilium"
  }

  assert {
    condition     = var.cilium_hubble.enabled == false
    error_message = "Expected hubble to be disabled by default"
  }
}

run "hubble_enabled_with_cilium" {
  command = plan

  variables {
    networking_cni = "cilium"
    cilium_hubble = {
      enabled = true
    }
  }

  assert {
    condition     = var.cilium_hubble.enabled == true
    error_message = "Expected hubble to be enabled"
  }
}

run "hubble_default_metrics" {
  command = plan

  variables {
    networking_cni = "cilium"
    cilium_hubble = {
      enabled = true
    }
  }

  assert {
    condition     = length(var.cilium_hubble.metrics) == 9
    error_message = "Expected 9 default metrics, got ${length(var.cilium_hubble.metrics)}"
  }
}

run "hubble_custom_metrics" {
  command = plan

  variables {
    networking_cni = "cilium"
    cilium_hubble = {
      enabled = true
      metrics = ["dns", "drop"]
    }
  }

  assert {
    condition     = length(var.cilium_hubble.metrics) == 2
    error_message = "Expected 2 custom metrics, got ${length(var.cilium_hubble.metrics)}"
  }
}

run "hubble_with_calico_fails" {
  command = plan

  variables {
    networking_cni = "calico"
    cilium_hubble = {
      enabled = true
    }
  }

  expect_failures = [
    null_resource.hubble_requires_cilium,
  ]
}

run "hubble_disabled_with_calico_succeeds" {
  command = plan

  variables {
    networking_cni = "calico"
  }

  assert {
    condition     = var.cilium_hubble.enabled == false
    error_message = "Expected hubble to be disabled"
  }
}
