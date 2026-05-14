# modules/iam/outputs.tf

output "group_administrador_arn" {
  description = "ARN do grupo AulaAdministrador."
  value       = aws_iam_group.administrador.arn
}

output "group_somente_leitura_arn" {
  description = "ARN do grupo AulasomenteLeitura."
  value       = aws_iam_group.somente_leitura.arn
}

output "group_financeiro_arn" {
  description = "ARN do grupo AulaFinanceiro."
  value       = aws_iam_group.financeiro.arn
}

output "group_ec2_devs_arn" {
  description = "ARN do grupo AulaEC2devs."
  value       = aws_iam_group.ec2_devs.arn
}

output "group_names" {
  description = "Nomes de todos os grupos IAM criados."
  value = {
    administrador  = aws_iam_group.administrador.name
    somente_leitura = aws_iam_group.somente_leitura.name
    financeiro     = aws_iam_group.financeiro.name
    ec2_devs       = aws_iam_group.ec2_devs.name
  }
}
