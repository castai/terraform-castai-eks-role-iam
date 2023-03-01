<a href="https://cast.ai">
    <img src="https://cast.ai/wp-content/themes/cast/img/cast-logo-dark-blue.svg" align="right" height="100" />
</a>

Terraform module for creating AWS IAM resources required to connect EKS with CAST AI, providing access through AssumeRole IAM.
==================


Website: https://www.cast.ai

Requirements
------------

- [Terraform](https://www.terraform.io/downloads.html) 0.13+

Using the module
------------

A module to create AWS IAM policies and a role to connect to CAST.AI

Requires `castai/castai` and `hashicorp/aws` providers to be configured.

```hcl
module "castai-eks-iam-role" {
  source = "castai/eks-role-iam/castai"

  aws_account_id     = var.aws_account_id
  aws_cluster_vpc_id = var.aws_vpc_id
  aws_cluster_region = var.aws_cluster_region
  aws_cluster_name   = var.aws_cluster_name
}
```

# Examples

Usage examples are located in [terraform provider repo](https://github.com/castai/terraform-provider-castai/tree/master/examples/eks)
