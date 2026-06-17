data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "podinfo-tfstate-52133295"
    key    = "infra/terraform.tfstate"
    region = "us-east-2"
  }
}

# external-dns's IAM policy scopes route53 writes to the hosted zone — that
# zone lives in bootstrap/, so apps reads it directly from bootstrap's state
# rather than asking infra to republish it.
data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket = "podinfo-tfstate-52133295"
    key    = "bootstrap/terraform.tfstate"
    region = "us-east-2"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}
