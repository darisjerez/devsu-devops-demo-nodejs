output "ecr_repository_url" {
  description = "URL of the ecr repository for docker images"
  value       = module.ecr.repository_url
}

output "eks_cluster_name" {
  description = "Name of the eks cluster"
  value       = module.eks_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the eks cluster API server"
  value       = module.eks_cluster.cluster_endpoint
}

output "kubectl_config_command" {
  description = "Command to configure kubectl for the eks cluster"
  value       = var.enable_eks ? "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}" : null
}

output "docker_login_command" {
  description = "Command to authenticate docker with ecr"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${module.ecr.repository_url}"
}

output "agent_public_ip" {
  description = "Public IP address of the ci/cd build agent"
  value       = module.agent.public_ip
}
