locals {
  resource_name_postfix = var.aws_cluster_name

  iam_role_name              = "castai-eks-${substr(local.resource_name_postfix, 0, 53)}"
  iam_policy_name            = var.create_iam_resources_per_cluster ? "CastEKSPolicy-${local.resource_name_postfix}" : "CastEKSPolicy-tf"
  iam_role_policy_name       = "castai-user-policy-${substr(local.resource_name_postfix, 0, 45)}"
  instance_profile_role_name = "castai-eks-instance-${substr(local.resource_name_postfix, 0, 44)}"
  iam_policy_prefix          = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  ipv6_policy_name           = "CastEC2AssignIPv6Policy-${local.resource_name_postfix}"

  castai_instance_profile_policy_list = merge(
    # Mandatory policies
    {
      AmazonEKSWorkerNodePolicy          = "${local.iam_policy_prefix}/AmazonEKSWorkerNodePolicy",
      AmazonEC2ContainerRegistryReadOnly = "${local.iam_policy_prefix}/AmazonEC2ContainerRegistryReadOnly"
    },
    # Optional policies
    var.attach_worker_cni_policy ? {
      AmazonEKS_CNI_Policy = "${local.iam_policy_prefix}/AmazonEKS_CNI_Policy"
    } : {},
    var.attach_ebs_csi_driver_policy ? {
      AmazonEBSCSIDriverPolicy = "${local.iam_policy_prefix}/service-role/AmazonEBSCSIDriverPolicy"
    } : {},
    var.attach_ssm_managed_instance_core ? {
      AmazonSSMManagedInstanceCore = "${local.iam_policy_prefix}/AmazonSSMManagedInstanceCore"
    } : {},
  )
}

data "aws_partition" "current" {}

# castai eks settings (provides required iam policies)

data "castai_eks_settings" "eks" {
  account_id            = var.aws_account_id
  vpc                   = var.aws_cluster_vpc_id
  region                = var.aws_cluster_region
  cluster               = var.aws_cluster_name
  shared_vpc_account_id = var.aws_shared_vpc_account_id
}

resource "aws_iam_role_policy_attachment" "castai_iam_policy_attachment" {
  role       = aws_iam_role.cast_role.name
  policy_arn = aws_iam_policy.castai_iam_policy.arn
}

resource "aws_iam_role" "cast_role" {
  name               = local.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.cast_assume_role_policy.json
}

resource "aws_iam_policy" "castai_iam_policy" {
  name   = local.iam_policy_name
  policy = data.castai_eks_settings.eks.iam_policy_json
}

resource "aws_iam_role_policy_attachment" "castai_iam_readonly_policy_attachment" {
  for_each = {
    AmazonEC2ReadOnlyAccess = "${local.iam_policy_prefix}/AmazonEC2ReadOnlyAccess",
    IAMReadOnlyAccess       = "${local.iam_policy_prefix}/IAMReadOnlyAccess",
  }
  role       = aws_iam_role.cast_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "castai_role_iam_policy" {
  name   = local.iam_role_policy_name
  role   = aws_iam_role.cast_role.name
  policy = data.castai_eks_settings.eks.iam_user_policy_json
}
# iam - instance profile role

resource "aws_iam_role" "instance_profile_role" {
  name                 = local.instance_profile_role_name
  max_session_duration = var.max_session_duration
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = local.instance_profile_role_name
  role = aws_iam_role.instance_profile_role.name
}

resource "aws_iam_role_policy_attachment" "castai_instance_profile_policy" {
  for_each = local.castai_instance_profile_policy_list

  role       = aws_iam_instance_profile.instance_profile.role
  policy_arn = each.value
}

# Create the IAM Policy for IPv6 assignment
resource "aws_iam_policy" "ec2_assign_ipv6" {
  count       = var.enable_ipv6 ? 1 : 0
  name        = local.ipv6_policy_name
  description = "Policy to allow EC2 to assign IPv6 addresses"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ec2:AssignIpv6Addresses",
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the role associated with the instance profile
resource "aws_iam_role_policy_attachment" "attach_ec2_assign_ipv6" {
  count      = var.enable_ipv6 ? 1 : 0
  role       = aws_iam_instance_profile.instance_profile.role
  policy_arn = aws_iam_policy.ec2_assign_ipv6[0].arn
}

data "aws_iam_policy_document" "cast_assume_role_policy" {
  statement {
    sid     = ""
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.castai_user_arn]
    }

    dynamic "condition" {
      for_each = var.castai_user_external_id != null ? [1] : []
      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [var.castai_user_external_id]
      }
    }
  }
}
