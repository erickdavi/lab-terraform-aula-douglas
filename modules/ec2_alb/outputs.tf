# modules/ec2_alb/outputs.tf

output "alb_arn" {
  description = "ARN do Application Load Balancer."
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS público do Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID do ALB (útil para criar registros DNS com Route 53)."
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN do Target Group."
  value       = aws_lb_target_group.main.arn
}

output "ec2_instance_id" {
  description = "ID da instância EC2."
  value       = aws_instance.main.id
}

output "ec2_private_ip" {
  description = "IP privado da instância EC2."
  value       = aws_instance.main.private_ip
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB."
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID do Security Group da EC2."
  value       = aws_security_group.ec2.id
}

output "waf_web_acl_arn" {
  description = "ARN do WAF Web ACL associado ao ALB."
  value       = aws_wafv2_web_acl.main.arn
}
