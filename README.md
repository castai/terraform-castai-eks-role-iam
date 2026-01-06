<a href="https://cast.ai">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/full-logo-white.svg">
    <source media="(prefers-color-scheme: light)" srcset=".github/full-logo-black.svg">
    <img src=".github/full-logo-black.svg" alt="Cast AI logo" title="Cast AI" align="right" height="50">
  </picture>
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
module "castai-eks-role-iam" {
  source = "castai/eks-role-iam/castai"

  aws_account_id     = var.aws_account_id
  aws_cluster_vpc_id = var.aws_vpc_id
  aws_cluster_region = var.aws_cluster_region
  aws_cluster_name   = var.aws_cluster_name
  castai_user_arn    = var.castai_user_arn
}
```

# Examples

Usage examples are located in [terraform provider repo](https://github.com/castai/terraform-provider-castai/tree/master/examples/eks)
