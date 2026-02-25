module "eks" {
  count   = var.enabled ? 1 : 0
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project_name}-eks"
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_security_group_additional_rules = {
    ingress_agent = {
      description              = "ci/cd agent access to cluster"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      type                     = "ingress"
      source_security_group_id = var.agent_security_group_id
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size
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
      principal_arn = var.agent_iam_role_arn
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
