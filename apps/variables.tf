variable "profile" {
  description = "AWS profile."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "name" {
  description = "Base name; used as a prefix and as the EKS cluster name."
  type        = string
  default     = "podinfo"
}

variable "domain_name" {
  description = "Route 53 hosted zone Terraform manages."
  type        = string
}

variable "subdomain" {
  description = "Host where podinfo will be served."
  type        = string
}

variable "podinfo_chart_version" {
  description = "Pin the podinfo Helm chart."
  type        = string
  default     = "6.7.1"
}
