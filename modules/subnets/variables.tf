#this module is just a template files when you use this module you must add values for your variables 
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where subnets, route tables, and NAT Gateway will be created"
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "CIDR block for the public subnet (e.g. 10.0.1.0/24)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets (e.g. [10.0.2.0/24, 10.0.3.0/24])"
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones used for subnets (one AZ per subnet)"
}