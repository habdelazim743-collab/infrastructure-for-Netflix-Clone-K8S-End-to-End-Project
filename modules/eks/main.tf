# EKS IAM role for the control plane
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

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS node group IAM role
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

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids

    # Keep the control plane accessible only via the private endpoint by default
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]
}

# Managed Node Group
resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-group-${var.cluster_name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = max(var.node_desired_size, length(var.private_subnet_ids))
    min_size     = max(var.node_min_size, length(var.private_subnet_ids))
    max_size     = max(var.node_max_size, length(var.private_subnet_ids))
  }

  instance_types = [var.node_instance_type]

  remote_access {
    ec2_ssh_key               = var.node_ssh_key_name
    source_security_group_ids = var.ssh_source_security_group_ids
  }

  depends_on = [aws_eks_cluster.cluster]
}

