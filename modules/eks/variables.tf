variable "cluster_name" {
  type        = string
  description = "Name for the EKS cluster"
  default     = "netflix-eks-cluster"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs where the EKS cluster and nodes will be created"

  validation {
    condition     = length(var.private_subnet_ids) >= 1
    error_message = "At least one private subnet ID must be provided to deploy the EKS cluster."
  }
}

variable "node_instance_type" {
  type        = string
  description = "Instance type for EKS worker nodes"
  default     = "t3.medium"
}

variable "node_min_size" {
  type        = number
  description = "Minimum number of nodes in the EKS managed node group"
  default     = 1
}

variable "node_ssh_key_name" {
  type        = string
  description = "Key pair name for SSH access to nodes (used by EKS node group's remote_access). Provide the key name created in the root module. Leave empty to skip."
  default     = ""
}

variable "ssh_source_security_group_ids" {
  type        = list(string)
  description = "List of security group ids that will be allowed to SSH to worker nodes via remote_access"
  default     = []
}

variable "node_desired_size" {
  type        = number
  description = "Desired number of nodes in the EKS managed node group"
  default     = 1
}

variable "node_max_size" {
  type        = number
  description = "Maximum number of nodes in the EKS managed node group"
  default     = 2
}


