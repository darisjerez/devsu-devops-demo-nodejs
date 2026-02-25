output "cluster_name" {
  description = "Name of the eks cluster"
  value       = var.enabled ? module.eks[0].cluster_name : null
}

output "cluster_endpoint" {
  description = "Endpoint of the eks cluster API server"
  value       = var.enabled ? module.eks[0].cluster_endpoint : null
}
