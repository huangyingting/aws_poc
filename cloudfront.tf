resource "aws_cloudfront_distribution" "cloudfront" {
  origin {
    domain_name = aws_elb.web.dns_name
    origin_id   = "ec2-cloudfront"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2", "SSLv3"]
    }
  }
  origin {
    domain_name = aws_s3_bucket.primary.bucket_regional_domain_name
    origin_id   = "s3-cloudfront-primary"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  origin {
    domain_name = aws_s3_bucket.failover.bucket_regional_domain_name
    origin_id   = "s3-cloudfront-failover"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  origin_group {
    origin_id = "s3-cloudfront"
    failover_criteria {
      status_codes = [403, 404, 500, 502]
    }
    member {
      origin_id = "s3-cloudfront-primary"
    }
    member {
      origin_id = "s3-cloudfront-failover"
    }
  }
  enabled         = true
  is_ipv6_enabled = false
  aliases         = ["aws.cnpro.org"]
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ec2-cloudfront"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  ordered_cache_behavior {
    path_pattern           = "*.svg"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-cloudfront"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_200"
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.aws_cnpro_org.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  web_acl_id = aws_wafv2_web_acl.wafv2.arn

  tags = {
    Project = "aws-poc"
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-aws-poc"
}
