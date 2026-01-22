variable "enable_eks" {
  default = false
}

variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "devsu-demo"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "eks_node_instance_type" {
  default = "t3.medium"
}

variable "eks_node_desired_count" {
  default = 2
}

variable "agent_instance_type" {
  default = "t3.medium"
}

variable "agent_key_name" {
  default = ""
}
