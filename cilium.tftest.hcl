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

run "cilium_defaults" {
  command = plan

  variables {
    networking_cni = "cilium"
  }

  assert {
    condition     = var.cilium.enable_remote_node_identity == true
    error_message = "Expected enable_remote_node_identity to default to true"
  }

  assert {
    condition     = var.cilium.preallocate_bpf_maps == true
    error_message = "Expected preallocate_bpf_maps to default to true"
  }

  assert {
    condition     = var.cilium.enable_node_port == true
    error_message = "Expected enable_node_port to default to true"
  }

  assert {
    condition     = var.cilium.enable_prometheus_metrics == true
    error_message = "Expected enable_prometheus_metrics to default to true"
  }
}

run "cilium_overrides" {
  command = plan

  variables {
    networking_cni = "cilium"
    cilium = {
      enable_remote_node_identity = false
      preallocate_bpf_maps        = false
      enable_node_port            = false
      enable_prometheus_metrics   = false
    }
  }

  assert {
    condition     = var.cilium.enable_remote_node_identity == false
    error_message = "Expected enable_remote_node_identity to be overridable"
  }

  assert {
    condition     = var.cilium.preallocate_bpf_maps == false
    error_message = "Expected preallocate_bpf_maps to be overridable"
  }

  assert {
    condition     = var.cilium.enable_node_port == false
    error_message = "Expected enable_node_port to be overridable"
  }

  assert {
    condition     = var.cilium.enable_prometheus_metrics == false
    error_message = "Expected enable_prometheus_metrics to be overridable"
  }
}

run "cilium_partial_override" {
  command = plan

  variables {
    networking_cni = "cilium"
    cilium = {
      enable_prometheus_metrics = false
    }
  }

  assert {
    condition     = var.cilium.enable_remote_node_identity == true
    error_message = "Expected unspecified fields to retain defaults"
  }

  assert {
    condition     = var.cilium.enable_prometheus_metrics == false
    error_message = "Expected enable_prometheus_metrics to be overridable"
  }
}
