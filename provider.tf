provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

# ==========================
# EKS Auth (for Kubernetes & Helm providers)
# ==========================
data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

# ==========================
# Kubernetes Provider
# ==========================
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

# ==========================
# Helm Provider
# ==========================
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}


