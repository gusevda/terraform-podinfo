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
  description = "Base name."
  type        = string
  default     = "podinfo"
}

variable "subdomain" {
  description = "Host where podinfo will be served."
  type        = string
}
