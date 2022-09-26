kind: Addons
metadata:
  name: addons
spec:
  addons:
    %{ for addon in addons }
    - manifest: ${ addon.name }/v${ addon.version }.yaml
      name: ${ addon.name }
      version: ${ addon.version }
      %{~ if lookup(addon, "kubernetes_version", null) != null ~}
      kubernetesVersion: '${ addon.kubernetes_version }'
      %{~ endif ~}
      manifestHash: ${ md5(addon.content) }
      selector:
        k8s-addon: ${ addon.name }
    %{ endfor }
