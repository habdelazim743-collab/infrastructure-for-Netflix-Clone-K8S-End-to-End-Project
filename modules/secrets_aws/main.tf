#############################################
# Keycloak Admin Secret (READ ONLY)
#############################################

data "aws_secretsmanager_secret" "keycloak_admin" {
  arn = var.keycloak_admin_secret_arn
}

data "aws_secretsmanager_secret_version" "keycloak_admin" {
  secret_id = data.aws_secretsmanager_secret.keycloak_admin.id
}

locals {
  keycloak_admin_secret = jsondecode(
    data.aws_secretsmanager_secret_version.keycloak_admin.secret_string
  )
}


