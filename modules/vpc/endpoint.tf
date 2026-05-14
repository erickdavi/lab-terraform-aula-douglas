# vpc/endpoint.tf

# Pega a região atual dinamicamente para construir o nome do serviço S3.
data "aws_region" "current" {}

resource "aws_vpc_endpoint_policy" "s3_endpoint_policy" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "*"
        Resource  = "*"
      },
    ]
  })
}

# Cria o S3 Gateway Endpoint de forma incondicional.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  # A Mágica: Junta os IDs de TODAS as tabelas de rotas que foram criadas.
  # Se uma camada de rede (ex: hml) estiver desligada, sua lista de IDs
  # estará vazia e será simplesmente ignorada pela função concat().
  route_table_ids = concat(
    aws_route_table.public[*].id,
    aws_route_table.production[*].id,
    aws_route_table.database[*].id,
    aws_route_table.dev[*].id,
    aws_route_table.hml[*].id
  )

  tags = merge(local.common_tags, {
    Name     = "${local.project_name}-S3-Endpoint"
    Produto  = "S3 Endpoint"
    Ambiente = "Infraestrutura"
  })
}