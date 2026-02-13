variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "alb_controller_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  type        = string
}
variable "external_secrets_role_arn" {
  type = string
}
variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS is deployed"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}
# New variables needed for EBS CSI driver
variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
variable "enable_k8s" {
  type = bool
}
