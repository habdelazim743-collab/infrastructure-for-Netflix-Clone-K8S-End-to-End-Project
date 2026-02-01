# please add this values to your infrastructure when use this module
# IAM Group Name
variable "group_name" {
  type        = string
  description = "Name of the IAM group that will be created to manage developers permissions."
}

# IAM Users List
variable "users" {
  type        = list(string)
  description = "List of IAM user names that will be created and added to the developers IAM group."
}
