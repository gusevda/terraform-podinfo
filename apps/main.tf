provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = local.common_tags
  }
}

locals {
  cluster_name        = data.terraform_remote_state.infra.outputs.cluster_name
  cluster_endpoint    = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca          = base64decode(data.terraform_remote_state.infra.outputs.cluster_ca_certificate)
  oidc_provider_arn   = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  oidc_provider_url   = data.terraform_remote_state.infra.outputs.oidc_provider_url
  vpc_id              = data.terraform_remote_state.infra.outputs.vpc_id
  acm_certificate_arn = data.terraform_remote_state.infra.outputs.acm_certificate_arn
  zone_id             = data.terraform_remote_state.bootstrap.outputs.zone_id
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
