terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "agent" {
  source = "./modules/agent"

  project_name  = var.project_name
  vpc_id        = module.networking.vpc_id
  subnet_id     = module.networking.public_subnets[0]
  instance_type = var.agent_instance_type
  key_name      = var.agent_key_name
}

module "eks_cluster" {
  source = "./modules/eks"

  enabled                 = var.enable_eks
  project_name            = var.project_name
  vpc_id                  = module.networking.vpc_id
  subnet_ids              = module.networking.private_subnets
  node_instance_type      = var.eks_node_instance_type
  node_desired_size       = var.eks_node_desired_count
  agent_security_group_id = module.agent.security_group_id
  agent_iam_role_arn      = module.agent.iam_role_arn
}
