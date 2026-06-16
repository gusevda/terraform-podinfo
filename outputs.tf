output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "kubeconfig_update_command" {
  description = "Run this to point kubectl at the cluster."
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.region}"
}

output "podinfo_url" {
  value = "https://${var.subdomain}"
}

output "podinfo_zone_nameservers" {
  description = "Add these as NS records for 'podinfo' in GoDaddy."
  value       = aws_route53_zone.podinfo.name_servers
}
