# IAM Group Name Output
output "iam_group_name" {
  description = "The name of the IAM group created for developers."
  value       = aws_iam_group.developers.name
}

# IAM Users Names Output
output "iam_users" {
  description = "List of IAM user names created and added to the developers group."
  value = [
    for user in aws_iam_user.users : user.name
  ]
}

# IAM Group ARN
output "iam_group_arn" {
  description = "ARN of the IAM group created for developers."
  value       = aws_iam_group.developers.arn
}

# Jenkins IAM Role & Instance Profile outputs
output "jenkins_iam_role_name" {
  description = "Name of the IAM role created for the Jenkins EC2 instance."
  value       = aws_iam_role.jenkins_ec2_role.name
}

output "jenkins_instance_profile_name" {
  description = "Instance profile name to attach to the Jenkins EC2 instance."
  value       = aws_iam_instance_profile.jenkins_instance_profile.name
}
