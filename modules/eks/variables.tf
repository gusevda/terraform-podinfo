variable "name" {
  description = "Cluster name; also used as a prefix for related IAM roles."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version, e.g. \"1.30\"."
  type        = string
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to hit the public EKS API endpoint."
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for the managed node group."
  type        = string
}

variable "subnet_ids" {
  description = "All subnet IDs the cluster control plane should attach ENIs in (typically the union of public and private subnets)."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnets for the managed node group (typically the private subnets)."
  type        = list(string)
}

variable "node_group_scaling" {
  description = "Desired/min/max node count."
  type = object({
    desired_size = number
    min_size     = number
    max_size     = number
  })
  default = {
    desired_size = 2
    min_size     = 2
    max_size     = 4
  }
}

variable "node_group_extra_depends_on" {
  description = "Extra resource IDs the node group must wait on (e.g. NAT gateway, route-table associations). Threaded through terraform_data as a sync point — pass IDs, not whole resource objects, so the input has a stable string shape and doesn't trip the 'inconsistent final plan' bug on resources with optional unset attributes. Don't use module-level depends_on for this — it forces all module outputs unknown at plan time and breaks providers that consume them."
  type        = list(string)
  default     = []
}
