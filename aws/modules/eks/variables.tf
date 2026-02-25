variable "enabled" {
  description = "Enable creation of the eks cluster"
  type        = bool
  default     = false
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the eks cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID of the vpc where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the private subnets for cluster nodes"
  type        = list(string)
}

variable "agent_security_group_id" {
  description = "Security group ID of the ci/cd agent for cluster access"
  type        = string
}

variable "agent_iam_role_arn" {
  description = "IAM role ARN of the ci/cd agent for cluster access"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for cluster nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}
