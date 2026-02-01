resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
  }
}
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    yamlencode({
      clusterName = var.cluster_name

      serviceAccount = {
        create = false
        name   = kubernetes_service_account.alb_controller.metadata[0].name
      }
    })
  ]

  depends_on = [
    kubernetes_service_account.alb_controller
  ]
}
