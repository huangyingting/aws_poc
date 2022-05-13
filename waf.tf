resource "aws_wafv2_web_acl" "wafv2" {
  name  = "aws-poc-wafv2"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = false
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "aws-poc-wafv2"
    sampled_requests_enabled   = false
  }
  tags = {
    Project = "aws-poc"
  }
  provider = aws.virginia
}