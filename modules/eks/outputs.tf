#############################################
# EKS OUTPUTS
#############################################

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint"
  value       = aws_eks_cluster.cluster.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64-encoded CA certificate for kubectl authentication"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group attached to the EKS control plane"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Name of the managed EKS node group"
  value       = aws_eks_node_group.managed_nodes.node_group_name
}

#############################################
# IRSA (IAM Roles for Service Accounts)
#############################################

output "oidc_issuer_url" {
  description = "OIDC issuer URL used for IRSA"
  value       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider associated with EKS"
  value       = data.aws_iam_openid_connect_provider.eks.arn
}



