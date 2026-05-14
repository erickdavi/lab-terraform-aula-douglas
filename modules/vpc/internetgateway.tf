# vpc/internetgateway.tf
resource "aws_internet_gateway" "igw" {
  # Só cria o IGW se as subnets públicas forem solicitadas
  count  = var.create_public_subnets
  vpc_id = aws_vpc.main.id
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-IGW"
  })
}