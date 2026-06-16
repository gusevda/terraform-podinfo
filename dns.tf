resource "aws_route53_zone" "podinfo" {
  name = var.subdomain
}

resource "aws_acm_certificate" "podinfo" {
  domain_name       = var.subdomain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "podinfo_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.podinfo.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.podinfo.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "podinfo" {
  certificate_arn         = aws_acm_certificate.podinfo.arn
  validation_record_fqdns = [for r in aws_route53_record.podinfo_cert_validation : r.fqdn]
}
