
#############################################
# Variables
#############################################
variable "environment" {
  type        = string
  description = "Environment name (dev/staging/prod)"
}
variable "keycloak_admin_secret_arn" {
  type        = string
  description = "ARN of the existing Keycloak admin secret in AWS Secrets Manager"
}

