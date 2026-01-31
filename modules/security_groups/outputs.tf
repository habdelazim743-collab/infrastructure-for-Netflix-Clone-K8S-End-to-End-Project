output "public_security_group_id" {
  description = "ID of the public EC2 security group for Jenkins and other public instances"
  value       = aws_security_group.public_ec2_sg.id
}