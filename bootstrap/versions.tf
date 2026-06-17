terraform {  
  backend "s3" {
    bucket         = "podinfo-tfstate-52133295"
    key            = "bootstrap/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "podinfo-tfstate-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">=1.5"
}
