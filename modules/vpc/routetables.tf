#############################
# PUBLIC ROUTE TABLE
#############################

resource "aws_route_table" "public" {
  count  = var.create_public_subnets
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = merge(local.common_tags, { 
    Name = "${local.project_name}-Public-RT" 
  })
}

resource "aws_route_table_association" "public" {
  count          = var.create_public_subnets == 1 ? var.availability_zones_count : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

#############################
# PRODUCTION ROUTE TABLE
#############################

resource "aws_route_table" "production" {
  count  = var.create_production_subnets
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.create_nat_gateway == 1 ? [1] : []  
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(local.common_tags, { 
    Name = "${local.project_name}-Production-RT" 
  })
}

resource "aws_route_table_association" "production" {
  count          = var.create_production_subnets == 1 ? var.availability_zones_count : 0
  subnet_id      = aws_subnet.production[count.index].id
  route_table_id = aws_route_table.production[0].id
}

#############################
# DATABASE ROUTE TABLE
#############################

resource "aws_route_table" "database" {
  count  = var.create_database_subnets
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.create_nat_gateway == 1 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(local.common_tags, { 
    Name = "${local.project_name}-Database-RT" 
  })
}

resource "aws_route_table_association" "database" {
  count          = var.create_database_subnets == 1 ? var.availability_zones_count : 0
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

#############################
# DEV ROUTE TABLE
#############################

resource "aws_route_table" "dev" {
  count  = var.create_dev_subnets
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.create_nat_gateway == 1 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(local.common_tags, { 
    Name = "${local.project_name}-Dev-RT" 
  })
}

resource "aws_route_table_association" "dev" {
  count          = var.create_dev_subnets == 1 ? var.availability_zones_count : 0
  subnet_id      = aws_subnet.dev[count.index].id
  route_table_id = aws_route_table.dev[0].id
}

#############################
# HML ROUTE TABLE
#############################

resource "aws_route_table" "hml" {
  count  = var.create_hml_subnets
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.create_nat_gateway == 1 ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[0].id
    }
  }

  tags = merge(local.common_tags, { 
    Name = "${local.project_name}-Hml-RT" 
  })
}

resource "aws_route_table_association" "hml" {
  count          = var.create_hml_subnets == 1 ? var.availability_zones_count : 0
  subnet_id      = aws_subnet.hml[count.index].id
  route_table_id = aws_route_table.hml[0].id
}
