
# AWS Region
variable "aws_region" {
  type        = string
  description = "AWS region where the infrastructure will be deployed"
  default     = "us-east-1"
}
# VPC Configuration
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC network"
  default     = "10.0.0.0/16"
}
variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
  default     = "Netflix-vpc"
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones where subnets will be created"
  default     = ["us-east-1a", "us-east-1b"]
}

# ==========================
# IAM Configuration
# ==========================
variable "iam_group_name" {
  type        = string
  description = "Name of the IAM group for developers"
  default     = "developers"
}

variable "iam_users" {
  type        = list(string)
  description = "List of IAM users to add to the developers group"
  default     = ["user1"]
}

# ==========================
# EC2 Example Configuration
# ==========================
variable "ec2_instance_type" {
  type        = string
  description = "Instance type for the public EC2 (Jenkins)"
  default     = "t2.small"
}

# ==========================
# EKS Cluster Configuration
# ==========================
variable "eks_cluster_name" {
  type        = string
  description = "Name for the EKS cluster"
  default     = "netflix-eks-cluster"
}

variable "eks_node_instance_type" {
  type        = string
  description = "Instance type for EKS worker nodes"
  default     = "t3.xlarge"
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum nodes in the EKS node group"
  default     = 2
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired nodes in the EKS node group"
  default     = 2
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum nodes in the EKS node group"
  default     = 3
}

# ==========================
# Jenkins / SSH Keys
# ==========================
variable "jenkins_user_public_key" {
  type        = string
  description = "Public SSH key for Jenkins EC2 (from GitHub Secret)"
  default     = ""
}

variable "jenkins_user_key_name" {
  type        = string
  description = "Key name for Jenkins EC2"
  default     = "jenkins-user-key"
}

variable "jenkins_nodes_key_name" {
  type        = string
  description = "Key name for Jenkins to SSH into EKS nodes"
  default     = "jenkins-nodes-key"
}

variable "jenkins_nodes_public_key" {
  type        = string
  description = "Public key Jenkins uses for EKS nodes (from GitHub Secret)"
  default     = ""
}

variable "jenkins_nodes_private_key" {
  type        = string
  description = "Private key Jenkins uses to SSH into EKS nodes (from GitHub Secret)"
  default     = ""
}
variable "keycloak_db_secret_arn" {
  description = "ARN of the existing RDS-managed secret for the Keycloak database"
  type        = string
  default     = "arn:aws:secretsmanager:us-east-1:231056963705:secret:keycloak-db-mu2bry"
}
#variable "keycloak_admin_password" {
  #type      = string
  #sensitive = true
 # description = "Keycloak admin password"
#}
variable "enable_k8s" {
  type    = bool
  default = true
}
variable "keycloak_admin_secret_arn" {
  type    = string
  default = "arn:aws:secretsmanager:us-east-1:231056963705:secret:keycloak-admin-LqFkna"
}

