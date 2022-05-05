# terraform-k8s

Module for creating Kubernetes clusters using kOps

## What is configured

* Kubernetes cluster using [kOps](https://kops.sigs.k8s.io) with RBAC authentication enabled
* Support for [custom addons](https://kops.sigs.k8s.io/addons/#custom-addons)
* [AWS IAM Authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) is configured to allow access using
  AWS Iam roles

TODOs:

* IAM Auth role mapping?
* Docs
* Cleanup
* Output?

### Custom addons

## Upgrading from 0.3.0 to 0.4.0

Due to changes in the AWS Load Balancer Controller with regard to tagging resources you need to add the
tag `KubernetesCluster=<your cluster name>` to load balancers, target groups, listeners, rules and security groups. This
can be achieved by running the following script with your cluster name and the AWS region as parameters.

```shell
#!/usr/bin/env bash

CLUSTER="$1"
REGION=${2:-$AWS_REGION}

function has_tag() {
  arn=$1
  aws elbv2 --region "${REGION}" describe-tags --resource-arns "$arn" --output text --query 'TagDescriptions[*].Tags[*].[Key,Value]' | grep -Ec "elbv2.k8s.aws/cluster\s+${CLUSTER}"
}

LBS=$(aws elbv2 --region "${REGION}" describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text)

for arn in ${LBS}; do
  count=$(has_tag "$arn")
  if [ "$count" -eq 1 ]; then
    aws elbv2 --region "${REGION}" add-tags --resource-arns "$arn" --tags "Key=KubernetesCluster,Value=${CLUSTER}"
  fi

  tgs=$(aws elbv2 --region "${REGION}" describe-target-groups --load-balancer-arn "$arn" --output text --query 'TargetGroups[*].TargetGroupArn')
  for tg in ${tgs}; do
    count=$(has_tag "$tg")
    if [ "$count" -eq 1 ]; then
      aws elbv2 --region "${REGION}" add-tags --resource-arns "$tg" --tags "Key=KubernetesCluster,Value=${CLUSTER}"
    fi
  done

  listeners=$(aws elbv2 --region "${REGION}" describe-listeners --load-balancer-arn "$arn" --output text --query 'Listeners[*].ListenerArn')
  for listener in ${listeners}; do
    count=$(has_tag "$listener")
    if [ "$count" -eq 1 ]; then
      aws elbv2 --region "${REGION}" add-tags --resource-arns "$listener" --tags "Key=KubernetesCluster,Value=${CLUSTER}"
    fi

    rules=$(aws elbv2 --region "${REGION}" describe-rules --listener-arn "$listener" --output text --query 'Rules[*].RuleArn')
    for rule in ${rules}; do
      count=$(has_tag "$rule")
      if [ "$count" -eq 1 ]; then
        aws elbv2 --region "${REGION}" add-tags --resource-arns "$rule" --tags "Key=KubernetesCluster,Value=${CLUSTER}"
      fi
    done
  done
done

sgs=$(aws ec2 describe-security-groups --region "${REGION}" --filter "Name=tag:elbv2.k8s.aws/cluster,Values=${CLUSTER}" --output text --query 'SecurityGroups[*].GroupId')
for sg in $sgs; do
  aws ec2 --region "$REGION" create-tags --resources "$sg" --tags "Key=KubernetesCluster,Value=${CLUSTER}"
done
```

## Example

A bunch of examples can be found under [examples](./examples).

  ````terraform
module "k8s" {
  source             = "opzkit/k8s/aws"
  name               = local.name
  state_store        = local.state_store
  region             = local.region
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  utility_subnet_ids = module.network.utility_subnet_ids
  admin_ssh_key      = var.kops_ssh_pub_key
  dns_zone           = aws_route53_zone.infra.name
  extra_addons       = [
    {
      name : "argocd"
      version : "0.0.1"
      content : local.argocd_yaml
    }
  ]
  service_account_external_permissions = [
    local.external_permissions_external_dns
  ]

  providers = {
    kops = kops
  }
}

locals {
  external_permissions_external_dns = {
    name      = "external-dns"
    namespace = "kube-system"
    aws       = {
      inline_policy = <<EOT
              [
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
      EOT
    }
  }
}
````
