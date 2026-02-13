variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where EC2 will be launched"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups attached to EC2"
}

variable "key_name" {
  type        = string
  description = "SSH key name for EC2 access"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile for EC2"
}

variable "jenkins_nodes_private_key" {
  type        = string
  description = "Private SSH key used by Jenkins to access nodes"
  sensitive   = true
}

variable "instance_name" {
  type        = string
  description = "Name tag of the EC2 instance"
  default     = "jenkins-ec2"
}
