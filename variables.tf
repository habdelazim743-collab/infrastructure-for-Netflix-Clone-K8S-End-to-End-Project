# ALL variables you'll need in your infra
variable "aws_region" {
  type        = string
  description = "AWS region where the infrastructure will be deployed"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC network"
  default     = "10.0.0.0/16"
}
# your vpc name 
variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
  default     = "Netflix-vpc"
}
# CIDR for public subnet
variable "public_subnet_cidr" {
  type        = list(string)
  description = "CIDR block for the public subnet"
  default     = [
    "10.0.1.0/24",
    "10.0.3.0/24"
  ]
}
# CIDR FOR private subnets (put subnets as you want in your infra )
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = [
    "10.0.2.0/24",
    "10.0.4.0/24"
  ]
}
# Availability zones that we will work in 
variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones where subnets will be created"
  default     = [
    "us-east-1a",
    "us-east-1b"
  ]
}
# IAM Group Name
variable "iam_group_name" {
  type        = string
  description = "Name of the IAM group that will be created for developers."
  default     = "developers"
}

# IAM Users List (put users as you want it will be dynamically created)
variable "iam_users" {
  type        = list(string)
  description = "List of IAM users to be created and added to the developers IAM group."
  default = [
    "user1"
  ]
}

# EC2 example variables
variable "ec2_instance_type" {
  type        = string
  description = "Instance type for the example EC2 in the public subnet"
  default     = "t3.medium"
}

# EKS variables
variable "eks_cluster_name" {
  type        = string
  description = "Name for the EKS cluster"
  default     = "netflix-eks-cluster"
}

variable "eks_node_instance_type" {
  type        = string
  description = "Instance type for EKS worker nodes"
  default     = "t3.medium"
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum number of nodes in the EKS managed node group"
  default     = 1
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired number of nodes in the EKS managed node group"
  default     = 1
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum number of nodes in the EKS managed node group"
  default     = 2
}

# Jenkins / SSH keys
variable "jenkins_user_public_key_path" {
  type        = string
  description = "Path to your local public SSH key file to allow SSH into the Jenkins EC2 (e.g. ~/.ssh/id_rsa.pub). Leave empty to skip."
  default     = "C:/Users/husseinelbarawy/.ssh/habdelazim.pub"
}

variable "jenkins_user_key_name" {
  type        = string
  description = "Name to register your public key as in AWS (used for SSH into Jenkins EC2)"
  default     = "jenkins-user-key"
}

variable "jenkins_nodes_key_name" {
  type        = string
  description = "Key-pair name for the key that Jenkins will use to SSH into private EKS nodes"
  default     = "jenkins-nodes-key"
}

variable "jenkins_nodes_public_key_path" {
  type        = string
  description = "Optional: Path to an existing local public key file (openssh .pub) to register in AWS for node access. Use absolute path (e.g., C:/Users/you/.ssh/jenkins_nodes.pub). If empty, Terraform will generate a keypair."
  default     = "C:/Users/husseinelbarawy/.ssh/jenkins_nodes.pub"
}

variable "jenkins_nodes_private_key_path" {
  type        = string
  description = "Optional: Path to your local private key file to be installed onto the Jenkins EC2 instance so Jenkins can SSH into nodes. If set, you must also set `jenkins_nodes_public_key_path`."
  default     = "C:/Users/husseinelbarawy/.ssh/jenkins_nodes"

  validation {
    condition     = var.jenkins_nodes_private_key_path == "" || var.jenkins_nodes_public_key_path != ""
    error_message = "If you set jenkins_nodes_private_key_path you must also set jenkins_nodes_public_key_path so the public key can be registered in AWS."
  }
}
