resource "aws_acm_certificate" "mwaa_access_cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  tags = {
    Name = "${var.mwaa_env_name} access certificate"
  }
}

resource "aws_acm_certificate_validation" "mwaa_access_cert" {
  certificate_arn         = aws_acm_certificate.mwaa_access_cert.arn
  validation_record_fqdns = [for k, v in aws_route53_record.mwaa_access_cert_validation : v.fqdn]
}

resource "aws_route53_record" "mwaa_access_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.mwaa_access_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_route53_record" "mwaa_alb_record" {
  zone_id = var.hosted_zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
