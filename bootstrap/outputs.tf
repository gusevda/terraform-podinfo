output "zone_id" {
  value = aws_route53_zone.podinfo.zone_id
}

output "zone_arn" {
  value = aws_route53_zone.podinfo.arn
}

output "zone_name" {
  value = aws_route53_zone.podinfo.name
}

output "nameservers" {
  description = "Add these as NS records for 'podinfo' in GoDaddy."
  value       = aws_route53_zone.podinfo.name_servers
}
