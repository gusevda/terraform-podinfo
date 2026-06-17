locals {
  common_tags = {
    Project     = var.name
    Environment = "demo"
    ManagedBy   = "terraform"
  }
}
