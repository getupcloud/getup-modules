# File auto-generated from ./bin/outputs

output "aws_account_id" {
  description = "AWS Account ID"
  value       = module.eks.aws_account_id
}

output "aws_region" {
  description = "AWS Region."
  value       = module.eks.aws_region
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.eks.cluster_platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.eks.cluster_status
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_vpc_id" {
  description = "ID of the cluster VPC"
  value       = module.eks.cluster_vpc_id
}

output "cluster_vpc_private_route_table_ids" {
  description = "Route table IDs from the cluster private subnets."
  value       = module.eks.cluster_vpc_private_route_table_ids
}

output "default_storage_class_name" {
  description = "Default StorageClass name"
  value       = module.eks.default_storage_class_name
}

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = module.eks.cluster_security_group_arn
}

output "cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = module.eks.node_security_group_arn
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider if `enable_irsa = true`"
  value       = module.eks.oidc_provider_arn
}

output "cluster_tls_certificate_sha1_fingerprint" {
  description = "The SHA1 fingerprint of the public key of the cluster's certificate"
  value       = module.eks.cluster_tls_certificate_sha1_fingerprint
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.eks.cluster_iam_role_unique_id
}

output "cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = module.eks.cluster_addons
}

output "aws_load_balancer_controller_iam_role_arn" {
  description = "AWS Load Balancer Controller Role ARN."
  value       = module.eks.aws_load_balancer_controller_iam_role_arn
}

output "cluster_identity_providers" {
  description = "Map of attribute maps for all EKS identity providers enabled"
  value       = module.eks.cluster_identity_providers
}

output "cloudwatch_log_group_name" {
  description = "Name of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "Arn of cloudwatch log group created"
  value       = module.eks.cloudwatch_log_group_arn
}

output "fargate_profiles" {
  description = "Map of attribute maps for all EKS Fargate Profiles created"
  value       = module.eks.fargate_profiles
}

output "eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.eks.eks_managed_node_groups
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.eks.eks_managed_node_groups_autoscaling_group_names
}

output "self_managed_node_groups" {
  description = "Map of attribute maps for all self managed node groups created"
  value       = module.eks.self_managed_node_groups
}

output "self_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by self-managed node groups"
  value       = module.eks.self_managed_node_groups_autoscaling_group_names
}

output "karpenter_iam_role_name" {
  description = "The name of the IAM role for service accounts"
  value       = module.eks.karpenter_iam_role_name
}

output "karpenter_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role for service accounts"
  value       = module.eks.karpenter_iam_role_arn
}

output "karpenter_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role for service accounts"
  value       = module.eks.karpenter_iam_role_unique_id
}

output "karpenter_queue_arn" {
  description = "The ARN of the SQS queue"
  value       = module.eks.karpenter_queue_arn
}

output "karpenter_queue_name" {
  description = "The name of the created Amazon SQS queue"
  value       = module.eks.karpenter_queue_name
}

output "karpenter_queue_url" {
  description = "The URL for the created Amazon SQS queue"
  value       = module.eks.karpenter_queue_url
}

output "karpenter_event_rules" {
  description = "Map of the event rules created and their attributes"
  value       = module.eks.karpenter_event_rules
}

output "karpenter_node_iam_role_name" {
  description = "The name of the IAM role"
  value       = module.eks.karpenter_node_iam_role_name
}

output "karpenter_node_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = module.eks.karpenter_node_iam_role_arn
}

output "karpenter_node_iam_role_unique_id" {
  description = "Stable and unique string identifying the IAM role"
  value       = module.eks.karpenter_node_iam_role_unique_id
}

output "karpenter_instance_profile_arn" {
  description = "ARN assigned by AWS to the instance profile"
  value       = module.eks.karpenter_instance_profile_arn
}

output "karpenter_instance_profile_id" {
  description = "Instance profile's ID"
  value       = module.eks.karpenter_instance_profile_id
}

output "karpenter_instance_profile_name" {
  description = "Name of the instance profile"
  value       = module.eks.karpenter_instance_profile_name
}

output "karpenter_instance_profile_unique" {
  description = "Stable and unique string identifying the IAM instance profile"
  value       = module.eks.karpenter_instance_profile_unique
}
