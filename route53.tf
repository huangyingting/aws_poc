data "aws_route53_zone" "public" {
  name         = "aws.cnpro.org"
  private_zone = false
}

resource "aws_acm_certificate" "aws_cnpro_org" {
  domain_name       = "aws.cnpro.org"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Project = "aws-poc"
  }
  provider = aws.virginia
}


resource "aws_route53_record" "cert_validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.aws_cnpro_org.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.aws_cnpro_org.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.aws_cnpro_org.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.public.id
  ttl             = 60
}


resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.aws_cnpro_org.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
  provider = aws.virginia
}

resource "aws_route53_record" "web" {
  zone_id = data.aws_route53_zone.public.id
  name    = "aws.cnpro.org"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cloudfront.domain_name
    zone_id                = aws_cloudfront_distribution.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
