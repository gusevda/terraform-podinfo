output "cluster_name" {
  value = module.eks.cluster_name
}

output "kubeconfig_update_command" {
  description = "Run this to point kubectl at the cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "podinfo_url" {
  value = "https://${var.subdomain}"
}
