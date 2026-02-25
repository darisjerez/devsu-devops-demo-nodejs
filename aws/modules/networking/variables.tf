variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the vpc"
  type        = string
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}
