# ==========================
# Terraform & Provider Versions
# ==========================
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# ==========================
# AWS Provider
# ==========================
provider "aws" {
  region = var.aws_region
}

# ==========================
# EKS Cluster Data
# ==========================
data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name

  depends_on = [
    module.eks
  ]
}

# ==========================
# EKS Auth (for Kubernetes & Helm providers)
# ==========================
data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name

  depends_on = [
    module.eks
  ]
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
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.this.token
  }
}