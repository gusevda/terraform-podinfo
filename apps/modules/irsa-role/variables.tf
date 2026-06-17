variable "name" {
  description = "Used as the IAM role name and to disambiguate resources."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace the service account lives in."
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name. Must match the chart's expected SA name."
  type        = string
}

variable "policy_arn" {
  description = "IAM policy ARN to attach to the role."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS cluster's IAM OIDC identity provider."
  type        = string
}

variable "oidc_provider_url" {
  description = "Issuer URL of the EKS cluster's IAM OIDC identity provider, with the leading https:// preserved."
  type        = string
}
