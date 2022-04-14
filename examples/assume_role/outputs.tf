output "role_arn" {
  value = module.castai-aws-iam.user_arn
}

output "instance_profile_arn" {
  value = module.castai-aws-iam.instance_profile_arn
}
