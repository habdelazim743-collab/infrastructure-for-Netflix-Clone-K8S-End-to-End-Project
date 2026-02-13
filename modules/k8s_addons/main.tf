############################################
# AWS Load Balancer Controller (ALB)
############################################

resource "kubernetes_service_account_v1" "alb_controller" {
  count = var.enable_k8s ? 1 : 0

  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
  }
}

resource "helm_release" "alb_controller" {
  count = var.enable_k8s ? 1 : 0

  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.1"

  timeout         = 900
  wait            = true
  wait_for_jobs   = true
  atomic          = true
  cleanup_on_fail = true

  values = [
    yamlencode({
      clusterName = var.cluster_name
      region      = var.aws_region
      vpcId       = var.vpc_id

      serviceAccount = {
        create = false
        name   = kubernetes_service_account_v1.alb_controller[0].metadata[0].name
      }
    })
  ]

  depends_on = [
    kubernetes_service_account_v1.alb_controller
  ]
}

resource "time_sleep" "wait_for_alb_webhook" {
  count = var.enable_k8s ? 1 : 0

  depends_on      = [helm_release.alb_controller[0]]
  create_duration = "90s"
}

############################################
# External Secrets Operator
############################################

resource "helm_release" "external_secrets" {
  count = var.enable_k8s ? 1 : 0

  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "2.0.0"

  create_namespace = true
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "external-secrets"
        annotations = {
          "eks.amazonaws.com/role-arn" = var.external_secrets_role_arn
        }
      }
    })
  ]

  depends_on = [
    time_sleep.wait_for_alb_webhook[0]
  ]
}

############################################
# Reloader
############################################

resource "helm_release" "reloader" {
  count = var.enable_k8s ? 1 : 0

  name       = "reloader"
  namespace  = "kube-system"
  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"

  timeout = 300
  wait    = true
}

############################################
# AWS EBS CSI Driver
############################################

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "${var.cluster_name}-ebs-csi-"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

data "aws_eks_addon_version" "ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.cluster_version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi_driver.version
  service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags
}

resource "time_sleep" "wait_for_ebs_csi" {
  count = var.enable_k8s ? 1 : 0

  depends_on      = [aws_eks_addon.ebs_csi_driver]
  create_duration = "30s"
}

############################################
# ArgoCD
############################################

resource "helm_release" "argocd" {
  count = var.enable_k8s ? 1 : 0

  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.6"

  create_namespace = true
  timeout          = 600
  wait             = true
  wait_for_jobs    = true

  values = [
    yamlencode({
      crds = {
        install = true
      }

      server = {
        service = {
          type = "ClusterIP"
        }
        extraArgs = ["--insecure"]
      }

      controller = {
        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }
      }

      repoServer = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      applicationSet = {
        enabled = true
      }
    })
  ]

  depends_on = [
    helm_release.external_secrets[0],
    time_sleep.wait_for_ebs_csi[0]
  ]
}

resource "time_sleep" "wait_for_argocd_crds" {
  count = var.enable_k8s ? 1 : 0

  depends_on      = [helm_release.argocd[0]]
  create_duration = "120s"
}

