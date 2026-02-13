variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}
variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}
