# modules/security/securityhub.tf

resource "aws_securityhub_account" "main" {
  enable_default_standards = false

  depends_on = [
    aws_guardduty_detector.main,
  ]
}

# AWS Foundational Security Best Practices v1.0.0
resource "aws_securityhub_standards_subscription" "aws_foundational" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.main]
}

# CIS AWS Foundations Benchmark v1.4.0
resource "aws_securityhub_standards_subscription" "cis_v140" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on    = [aws_securityhub_account.main]
}

# Integrações com outros serviços de segurança
resource "aws_securityhub_product_subscription" "guardduty" {
  product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/guardduty"
  depends_on  = [aws_securityhub_account.main]
}

# Inspector removido (bloqueado no AWS Academy)
