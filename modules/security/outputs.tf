# modules/security/outputs.tf

output "guardduty_detector_id" {
  description = "ID do detector do GuardDuty."
  value       = aws_guardduty_detector.main.id
}

output "cloudtrail_arn" {
  description = "ARN da trilha do CloudTrail."
  value       = aws_cloudtrail.main.arn
}

output "cloudtrail_s3_bucket_name" {
  description = "Nome do bucket S3 onde os logs do CloudTrail sao armazenados."
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "config_s3_bucket_name" {
  description = "Nome do bucket S3 onde os snapshots do AWS Config sao armazenados."
  value       = aws_s3_bucket.config.bucket
}

output "securityhub_id" {
  description = "ID da conta no Security Hub."
  value       = aws_securityhub_account.main.id
}
