# ==========================
# VPC Module
# ==========================
module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

# ==========================
# Subnets Module
# ==========================
module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id

  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.availability_zones
}

# ==========================
# IAM Module
# ==========================
module "iam" {
  source     = "./modules/iam"
  group_name = var.iam_group_name
  users      = var.iam_users
}

# ==========================
# Security Groups
# ==========================
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

# ==========================
# EC2 AMI Data
# ==========================
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ==========================
# Jenkins User Key Pair
# ==========================
resource "aws_key_pair" "jenkins_user" {
  count      = var.jenkins_user_public_key != "" ? 1 : 0
  key_name   = var.jenkins_user_key_name
  public_key = var.jenkins_user_public_key
}

# ==========================
# Jenkins Nodes Key Pair
# ==========================
resource "tls_private_key" "jenkins_nodes" {
  count     = var.jenkins_nodes_public_key == "" && var.jenkins_nodes_private_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_nodes" {
  key_name   = var.jenkins_nodes_key_name
  public_key = var.jenkins_nodes_public_key != "" ? var.jenkins_nodes_public_key : tls_private_key.jenkins_nodes[0].public_key_openssh
}

# ==========================
# Public EC2 (Jenkins)
# ==========================
resource "aws_instance" "public_ec2" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.ec2_instance_type
  subnet_id                   = module.subnets.public_subnet_cidr[0]
  vpc_security_group_ids      = [module.security_groups.public_security_group_id]
  associate_public_ip_address = true

  key_name             = length(aws_key_pair.jenkins_user) > 0 ? aws_key_pair.jenkins_user[0].key_name : null
  iam_instance_profile = module.iam.jenkins_instance_profile_name

  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /home/ec2-user/.ssh
    cat > /home/ec2-user/.ssh/jenkins_nodes_key <<'KEY'
${var.jenkins_nodes_private_key != "" ? var.jenkins_nodes_private_key : tls_private_key.jenkins_nodes[0].private_key_pem}
KEY
    chown ec2-user:ec2-user /home/ec2-user/.ssh/jenkins_nodes_key
    chmod 600 /home/ec2-user/.ssh/jenkins_nodes_key
  EOF

  tags = {
    Name = "public-ec2"
  }
}

# ==========================
# EKS Cluster
# ==========================
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.eks_cluster_name
  private_subnet_ids = module.subnets.private_subnet_cidrs
  node_instance_type = var.eks_node_instance_type
  node_min_size      = var.eks_node_min_size
  node_desired_size  = var.eks_node_desired_size
  node_max_size      = var.eks_node_max_size

  node_ssh_key_name             = aws_key_pair.jenkins_nodes.key_name
  ssh_source_security_group_ids = [module.security_groups.public_security_group_id]
}

# ==========================
# Allow Jenkins EC2 SG to access EKS control plane
# ==========================
resource "aws_security_group_rule" "allow_jenkins_to_eks_control_plane" {
  type                     = "ingress"
  description              = "Allow Jenkins EC2 (public-ec2-sg) to access EKS control plane (HTTPS)"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = module.security_groups.public_security_group_id
}
# ==========================
# IAM IRSA (ALB Controller)
# ==========================
module "iam_irsa" {
  source = "./modules/iam_irsa"

  oidc_issuer_url = module.eks.oidc_issuer_url
}
# ==========================
# Kubernetes Addons (ALB Controller)
# ==========================
module "k8s_addons" {
  source = "./modules/k8s_addons"

  cluster_name               = var.eks_cluster_name
  alb_controller_role_arn    = module.iam_irsa.alb_controller_role_arn
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = var.eks_cluster_name
}

