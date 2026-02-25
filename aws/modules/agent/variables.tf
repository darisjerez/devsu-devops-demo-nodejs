variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the vpc for the agent security group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the public subnet for the agent instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the ci/cd agent"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the ssh key pair for agent access"
  type        = string
  default     = ""
}
