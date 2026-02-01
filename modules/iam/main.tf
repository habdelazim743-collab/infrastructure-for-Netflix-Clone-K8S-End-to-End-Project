# Create IAM Group
# This resource creates an IAM group that will be used to manage permissions for all developer users in one place.
resource "aws_iam_group" "developers" {
  name = var.group_name
}

# Create IAM Users
# This resource creates multiple IAM users dynamically using for_each, The users names are provided from a list variable to make the module reusable.
resource "aws_iam_user" "users" {
  for_each = toset(var.users)
  name     = each.value
}

# Add Users to IAM Group
# This resource attaches all created IAM users to the developers group.
#Any new user added to the list will automatically join the group.
resource "aws_iam_group_membership" "developers_membership" {
  name = "developers-membership"

  users = [
    for user in aws_iam_user.users : user.name
  ]

  group = aws_iam_group.developers.name
}

# Attach Policies to IAM Group
# Policies are attached to the group instead of individual users 

# S3 Read/Write Access
resource "aws_iam_group_policy_attachment" "s3_rw" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# EC2 Admin Access
resource "aws_iam_group_policy_attachment" "ec2_admin" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# EKS Read/Write Access
resource "aws_iam_group_policy_attachment" "eks_rw" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# DynamoDB Read-Only Access
resource "aws_iam_group_policy_attachment" "dynamo_read" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

# RDS Read-Only Access
resource "aws_iam_group_policy_attachment" "rds_read" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

# IAM Role for Jenkins EC2 (allows Jenkins to interact with EKS and ECR)
resource "aws_iam_role" "jenkins_ec2_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_eks_policy" {
  name = "jenkins-eks-policy"
  role = aws_iam_role.jenkins_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListUpdates",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:AccessKubernetesApi"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_ec2_role.name
}


