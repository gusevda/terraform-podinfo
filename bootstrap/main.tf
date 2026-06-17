provider "aws" {
  region = var.region
  profile = var.profile

  default_tags {
    tags = {
      Project = var.name
      Layer   = "bootstrap"
    }
  }
}
