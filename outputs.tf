# outputs.tf

output "account" {
  description = "ID da conta AWS."
  value       = data.aws_caller_identity.current.account_id
}

output "arn" {
  description = "ARN do caller atual."
  value       = data.aws_caller_identity.current.arn
}

# --- VPC ---

output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.vpc.vpc_id
}

# --- EC2 / ALB ---

output "alb_dns_name" {
  description = "DNS publico do Application Load Balancer."
  value       = module.ec2_alb.alb_dns_name
}

output "ec2_instance_id" {
  description = "ID da instancia EC2."
  value       = module.ec2_alb.ec2_instance_id
}

output "ec2_private_ip" {
  description = "IP privado da instancia EC2."
  value       = module.ec2_alb.ec2_private_ip
}

output "waf_web_acl_arn" {
  description = "ARN do WAF Web ACL associado ao ALB."
  value       = module.ec2_alb.waf_web_acl_arn
}

# --- SEGURANÇA ---

output "cloudtrail_s3_bucket" {
  description = "Bucket S3 onde os logs do CloudTrail sao armazenados."
  value       = module.security.cloudtrail_s3_bucket_name
}

output "config_s3_bucket" {
  description = "Bucket S3 onde os snapshots do AWS Config sao armazenados."
  value       = module.security.config_s3_bucket_name
}

output "guardduty_detector_id" {
  description = "ID do detector do GuardDuty."
  value       = module.security.guardduty_detector_id
}

# --- IAM (desabilitado no AWS Academy) ---
# output "iam_groups" {
#   value = module.iam.group_names
# }
