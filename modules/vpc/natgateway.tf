# Criar EIP apenas se o NAT Gateway estiver habilitado
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway == 1 ? 1 : 0
  domain = "vpc"

  depends_on = [aws_internet_gateway.igw]

  tags = merge(local.common_tags, {
    Name     = "${local.project_name}-NAT-EIP"
    Produto  = "NatGateway"
    Ambiente = "Infraestrutura"
  })
}

# Criar NAT Gateway apenas se habilitado
resource "aws_nat_gateway" "main" {
  count = var.create_nat_gateway == 1 ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags, {
    Name     = "${local.project_name}-NAT-Gateway"
    Produto  = "NatGateway"
    Ambiente = "Infraestrutura"
  })
}
