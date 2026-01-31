# VPC Module

module "vpc" {
  source = "./modules/vpc"

  # VPC configuration
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

# Subnets Module

module "subnets" {
  source = "./modules/subnets"

  # VPC ID from VPC module
  vpc_id = module.vpc.vpc_id

  # Subnet configuration
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.availability_zones
}
# IAM Module
module "iam" {
  source = "./modules/iam"

  group_name = var.iam_group_name
  users      = var.iam_users
}

# EC2 example in the first public subnet (10.0.1.0/24 by default)
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "public_ec2_sg" {
  name   = "public-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Register your local public key (optional)
resource "aws_key_pair" "jenkins_user" {
  count      = var.jenkins_user_public_key_path != "" ? 1 : 0
  key_name   = var.jenkins_user_key_name
  public_key = file(var.jenkins_user_public_key_path)
}

# Generate SSH keypair for Jenkins to access private nodes (private key is written to Jenkins instance user_data)
resource "tls_private_key" "jenkins_nodes" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_nodes" {
  key_name = var.jenkins_nodes_key_name

  # Use a provided public key if present, otherwise use the generated key
  public_key = var.jenkins_nodes_public_key_path != "" ? file(var.jenkins_nodes_public_key_path) : tls_private_key.jenkins_nodes.public_key_openssh
}

resource "aws_instance" "public_ec2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.ec2_instance_type
  subnet_id              = module.subnets.public_subnet_cidr[0]
  vpc_security_group_ids = [aws_security_group.public_ec2_sg.id]
  associate_public_ip_address = true

  # Allow you (local key) to SSH in if you provided a path
  key_name = length(aws_key_pair.jenkins_user) > 0 ? aws_key_pair.jenkins_user[0].key_name : null
  iam_instance_profile = module.iam.jenkins_instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ec2-user/.ssh
              cat > /home/ec2-user/.ssh/jenkins_nodes_key <<'KEY'
${var.jenkins_nodes_private_key_path != "" ? file(var.jenkins_nodes_private_key_path) : tls_private_key.jenkins_nodes.private_key_pem}
KEY
              chown ec2-user:ec2-user /home/ec2-user/.ssh/jenkins_nodes_key
              chmod 600 /home/ec2-user/.ssh/jenkins_nodes_key
              EOF

  tags = {
    Name = "public-ec2"
  }
}

# EKS cluster module that deploys into the two private subnets
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.eks_cluster_name
  private_subnet_ids = module.subnets.private_subnet_cidrs
  node_instance_type = var.eks_node_instance_type
  node_min_size      = var.eks_node_min_size
  node_desired_size  = var.eks_node_desired_size
  node_max_size      = var.eks_node_max_size

  node_ssh_key_name = aws_key_pair.jenkins_nodes.key_name
  ssh_source_security_group_ids = [aws_security_group.public_ec2_sg.id]
}
