# vpc/outputs.tf
output "vpc_id" {
  description = "O ID da VPC criada."
  value       = aws_vpc.main.id
}
output "public_subnet_ids" {
  description = "IDs das sub-redes públicas. Retorna lista vazia se não foram criadas."
  value       = aws_subnet.public[*].id
}
output "production_subnet_ids" {
  description = "IDs das sub-redes de produção. Retorna lista vazia se não foram criadas."
  value       = aws_subnet.production[*].id
}
output "database_subnet_ids" {
  description = "IDs das sub-redes de banco de dados. Retorna lista vazia se não foram criadas."
  value       = aws_subnet.database[*].id
}
output "dev_subnet_ids" {
  description = "IDs das sub-redes de desenvolvimento. Retorna lista vazia se não foram criadas."
  value       = aws_subnet.dev[*].id
}
output "hml_subnet_ids" {
  description = "IDs das sub-redes de homologação. Retorna lista vazia se não foram criadas."
  value       = aws_subnet.hml[*].id
}