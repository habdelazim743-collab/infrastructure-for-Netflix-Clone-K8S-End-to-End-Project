output "alb_controller_sa_name" {
  value = kubernetes_service_account_v1.alb_controller.metadata[0].name
}
