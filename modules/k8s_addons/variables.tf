variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "alb_controller_role_arn" {
  description = "IAM Role ARN for AWS Load Balancer Controller"
  type        = string
}
