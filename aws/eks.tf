module "eks" {
  count   = var.enable_eks ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_security_group_additional_rules = {
    ingress_agent = {
      description              = "Agent access"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = aws_security_group.agent.id
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      instance_types = [var.eks_node_instance_type]
      min_size       = 1
      max_size       = 3
      desired_size   = var.eks_node_desired_count
    }
  }

  cluster_addons = {
    coredns        = { most_recent = true }
    kube-proxy     = { most_recent = true }
    vpc-cni        = { most_recent = true }
    metrics-server = { most_recent = true }
  }

  enable_cluster_creator_admin_permissions = true

  access_entries = {
    agent = {
      principal_arn = aws_iam_role.agent.arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}
