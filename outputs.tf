output "role_arn" {
  description = "Arn of created AWS user"
  value       = aws_iam_role.test_role.arn
}

output "instance_profile_arn" {
  description = "Arn of created instance profile"
  value       = aws_iam_instance_profile.instance_profile.arn
}

output "instance_profile_role_arn" {
  description = "Arn of created instance profile role"
  value       = aws_iam_role.instance_profile_role.arn
}

