# VPC
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

# Internet Gateway (from subnets module)
output "internet_gateway_id" {
  description = "ID of the Internet Gateway attached to the VPC."
  value       = module.subnets.internet_gateway_id
}

output "internet_gateway_name" {
  description = "Name tag of the Internet Gateway."
  value       = module.subnets.internet_gateway_name
}

# Subnets
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.subnets.private_subnet_ids
}


# NAT Gateway
output "nat_gateway_id" {
  description = "ID of the NAT Gateway used for outbound internet access from private subnets."
  value       = module.subnets.nat_gateway_id
}
# Elastic IP
output "nat_eip" {
  description = "Elastic IP associated with the NAT Gateway."
  value       = module.subnets.nat_eip
}

# Route Tables
output "public_route_table_id" {
  description = "Route table ID associated with the public subnet."
  value       = module.subnets.public_route_table_id
}

output "private_route_table_id" {
  description = "Route table ID associated with private subnets."
  value       = module.subnets.private_route_table_id
}

# IAM
output "iam_group_name" {
  description = "Name of the IAM group created for developers."
  value       = module.iam.iam_group_name
}

output "iam_users" {
  description = "List of IAM users created."
  value       = module.iam.iam_users
}

output "jenkins_public_ip" {
  description = "Public IP of Jenkins EC2"
  value       = module.jenkins_ec2.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS of Jenkins EC2"
  value       = module.jenkins_ec2.public_dns
}


# Name of auto-generated keypair used by Jenkins to SSH to nodes
output "jenkins_nodes_key_name" {
  description = "Key pair name created for Jenkins to SSH into EKS nodes"
  value       = aws_key_pair.jenkins_nodes.key_name
}
output "cluster_token" {
  value     = data.aws_eks_cluster_auth.this.token
  sensitive = true
}
#############################################
# RDS OUTPUTS
#############################################

output "keycloak_db_endpoint" {
  description = "Keycloak RDS endpoint"
  value       = module.rds.endpoint
}

output "keycloak_db_port" {
  description = "Keycloak RDS port"
  value       = module.rds.port
  sensitive   = true
}


