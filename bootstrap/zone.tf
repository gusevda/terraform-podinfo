resource "aws_route53_zone" "podinfo" {
  name = var.subdomain
}
