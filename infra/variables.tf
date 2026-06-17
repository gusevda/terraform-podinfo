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

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "kubeconfig_admin_ip" {
  description = "Your laptop's public IPv4 CIDR (e.g. 203.0.113.5/32). Restricts EKS public endpoint."
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for the managed node group."
  type        = string
  default     = "t3.medium"
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
