output "keycloak_admin_username" {
  value = local.keycloak_admin_secret["KEYCLOAK_ADMIN"]
}

output "keycloak_admin_password" {
  value     = local.keycloak_admin_secret["KEYCLOAK_ADMIN_PASSWORD"]
  sensitive = true
}
