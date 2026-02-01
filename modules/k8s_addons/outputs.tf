output "alb_controller_sa_name" {
  value = kubernetes_service_account.alb_controller.metadata[0].name
}
