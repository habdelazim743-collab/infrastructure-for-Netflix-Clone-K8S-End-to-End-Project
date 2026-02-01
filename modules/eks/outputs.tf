output "cluster_name" {
  value       = aws_eks_cluster.cluster.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.cluster.endpoint
  description = "EKS cluster endpoint"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
  description = "Security group ID attached to the EKS cluster control plane"
}

output "node_group_name" {
  value       = aws_eks_node_group.managed_nodes.node_group_name
  description = "Managed node group name"
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA"
  value       = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
output "cluster_ca_certificate" {
  description = "Base64 encoded CA certificate for the EKS cluster"
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
}



