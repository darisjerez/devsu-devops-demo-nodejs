variable "enable_eks" {
  description = "Enable creation of the eks cluster"
  type        = bool
  default     = false
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-2"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.aws_region))
    error_message = "Must be a valid AWS region"
  }
}

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "devsu-demo"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Must contain only lowercase letters and numbers."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the vpc"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid CIDR block."
  }
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for eks worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_count" {
  description = "Desired number of eks worker nodes"
  type        = number
  default     = 2

  validation {
    condition     = var.eks_node_desired_count >= 1 && var.eks_node_desired_count <= 10
    error_message = "Must be between 1 and 10."
  }
}

variable "agent_instance_type" {
  description = "EC2 instance type for the ci/cd build agent"
  type        = string
  default     = "t3.medium"
}

variable "agent_key_name" {
  description = "SSH key pair name for agent access"
  type        = string
  default     = ""
}
