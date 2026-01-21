moved {
  from = kops_instance_group.masters
  to   = kops_instance_group.control_plane
}

moved {
  from = kops_instance_group.nodes["a"]
  to   = kops_instance_group.nodes["nodes-a"]
}

moved {
  from = kops_instance_group.nodes["b"]
  to   = kops_instance_group.nodes["nodes-b"]
}

moved {
  from = kops_instance_group.nodes["c"]
  to   = kops_instance_group.nodes["nodes-c"]
}
