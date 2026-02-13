#############################################
# IAM ROLE FOR EKS CONTROL PLANE
#
# This role is assumed by the EKS service
# itself (control plane).
# It allows EKS to manage AWS resources
# such as ENIs, security groups, etc.
#############################################
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = { Service = "eks.amazonaws.com" },
        Effect    = "Allow",
        Sid       = ""
      }
    ]
  })
}
#############################################
# Attach required AWS managed policy
# for EKS control plane
#############################################
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

#############################################
# IAM ROLE FOR EKS WORKER NODES
#
# This role is assumed by EC2 instances
# that act as Kubernetes worker nodes.
#############################################
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = { Service = "ec2.amazonaws.com" },
        Effect    = "Allow",
        Sid       = ""
      }
    ]
  })
}
#############################################
# Required policies for worker nodes
#############################################
# Allows nodes to join the EKS cluster

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
# Allows pulling images from ECR

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
# Required for VPC CNI networking
resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#############################################
# EKS CLUSTER
#
# Control plane managed by AWS.
# Nodes will run in private subnets.
#############################################
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
        # Recommended setup:
    # - Private access enabled
    # - Public access enabled for kubectl / CI
    # Keep the control plane accessible only via the private endpoint by default
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]
}

#############################################
# EKS MANAGED NODE GROUP
#
# Worker nodes managed by AWS.
#############################################
resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-group-${var.cluster_name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  instance_types = [var.node_instance_type]

  remote_access {
    ec2_ssh_key               = var.node_ssh_key_name
    source_security_group_ids = var.ssh_source_security_group_ids
  }

  depends_on = [aws_eks_cluster.cluster]
}
# ==========================
# Reference existing OIDC Provider
# ==========================

data "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
