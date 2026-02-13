# this file will print the output of your creation in the screen
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}
# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.igw.id
}

output "internet_gateway_name" {
  description = "Name tag of the Internet Gateway."
  value       = aws_internet_gateway.igw.tags["Name"]
}
#NAT GATEWAY
output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = aws_nat_gateway.nat.id
}

output "nat_eip" {
  description = "Elastic IP attached to the NAT Gateway."
  value       = aws_eip.nat.public_ip
}

# Route Tables Outputs
output "public_route_table_id" {
  description = "Public route table ID."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID."
  value       = aws_route_table.private.id
}
