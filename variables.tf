variable "create_iam_resources_per_cluster" {
  description = "Whether to generate IAM resources bound to single cluster that otherwise would be reused."
  type        = bool
  default     = true
}

variable "aws_cluster_name" {
  type        = string
  description = "Name of the cluster IAM resources will be created for."
}

variable "aws_cluster_region" {
  type        = string
  description = "Region of the cluster IAM resources will created for."
}

variable "aws_cluster_vpc_id" {
  type        = string
  description = "VPC of the cluster IAM resources will created for."
}

variable "aws_account_id" {
  type        = string
  description = "ID of AWS account the cluster is located in."
}

variable "aws_shared_vpc_account_id" {
  description = "Optional AWS account ID where the VPC and subnets are located, for shared VPC setups"
  type        = string
  default     = null
}

variable "castai_user_arn" {
  type        = string
  description = "ARN of CAST AI user for which AssumeRole trust access should be granted"
}

variable "attach_worker_cni_policy" {
  type        = bool
  description = "Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster."
  default     = true
}

variable "attach_ebs_csi_driver_policy" {
  type        = bool
  description = "Whether to attach the Amazon managed `AmazonEBSCSIDriverPolicy` IAM policy"
  default     = true
}

variable "attach_ssm_managed_instance_core" {
  type        = bool
  description = "Whether to attach the Amazon managed `AmazonSSMManagedInstanceCore` IAM policy"
  default     = true
}

variable "enable_ipv6" {
  type        = bool
  description = "Whether to enable IPv6 CNI policy for the cluster."
  default     = true
}

variable "max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the specified role."
  type        = number
  default     = 3600
}

variable "castai_user_external_id" {
  description = "Optional external ID used in assume role policy condition"
  type        = string
  default     = null # Null because of backwards compatibility
}
