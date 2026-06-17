terraform {
  backend "s3" {
    bucket         = "podinfo-tfstate-52133295"
    key            = "apps/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "podinfo-tfstate-lock"
    encrypt        = true
  }

  required_providers {
    aws        = { source = "hashicorp/aws",        version = "~> 5.92" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.13" }
  }

  required_version = ">= 1.5"
}
