output "role_arn" {
  description = "ARN of the created IAM role; useful for Helm chart values."
  value = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the created IAM role."
  value = aws_iam_role.this.name
}

output "service_account_name" {
  description = "Echoes back the service-account name, so callers can use module.x.service_account_name."
  value = kubernetes_service_account.this.metadata[0].name
}
