output "alb_controller_sa_name" {
  value = var.enable_k8s ? try(
    kubernetes_service_account_v1.alb_controller[0].metadata[0].name,
    null
  ) : null
}




# EBS CSI Driver outputs
output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = module.ebs_csi_driver_irsa.iam_role_arn
}

output "ebs_csi_driver_addon_id" {
  description = "EBS CSI driver addon ID"
  value       = aws_eks_addon.ebs_csi_driver.id
}

output "ebs_csi_driver_addon_version" {
  description = "EBS CSI driver addon version"
  value       = aws_eks_addon.ebs_csi_driver.addon_version
}
