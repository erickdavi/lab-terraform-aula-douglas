# vpc/subnets.tf
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = var.create_public_subnets == 1 ? var.availability_zones_count : 0
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = local.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-Public-Subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "production" {
  count             = var.create_production_subnets == 1 ? var.availability_zones_count : 0
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = local.production_subnet_cidrs[count.index]
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-Production-Subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "database" {
  count             = var.create_database_subnets == 1 ? var.availability_zones_count : 0
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = local.database_subnet_cidrs[count.index]
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-Database-Subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "dev" {
  count             = var.create_dev_subnets == 1 ? var.availability_zones_count : 0
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = local.dev_subnet_cidrs[count.index]
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-Dev-Subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "hml" {
  count             = var.create_hml_subnets == 1 ? var.availability_zones_count : 0
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = local.hml_subnet_cidrs[count.index]
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-Hml-Subnet-${count.index + 1}"
  })
}