# vpc/nacl.tf

# --- NACL PÚBLICA ---
resource "aws_network_acl" "public" {
  count      = var.create_public_subnets
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(local.common_tags, { Name = "${local.project_name}-Public-NACL" })
}


# --- NACL DE PRODUÇÃO ---
resource "aws_network_acl" "production" {
  count      = var.create_production_subnets
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.production[*].id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = local.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  egress {
    rule_no    = 400
    protocol   = "-1"
    action     = "allow"
    cidr_block = local.vpc_cidr_block
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 410
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }
  egress {
    rule_no    = 420
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    rule_no    = 430
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = merge(local.common_tags, { Name = "${local.project_name}-Production-NACL" })
}


# --- NACL DO BANCO DE DADOS ---
resource "aws_network_acl" "database" {
  count      = var.create_database_subnets
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.database[*].id

  dynamic "ingress" {
    for_each = local.production_subnet_cidrs
    content {
      rule_no    = 100 + ingress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      to_port    = 0
    }
  }
  dynamic "ingress" {
    for_each = local.database_subnet_cidrs
    content {
      rule_no    = 105 + ingress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      to_port    = 0
    }
  }
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  dynamic "egress" {
    for_each = local.production_subnet_cidrs
    content {
      rule_no    = 400 + egress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 0
      to_port    = 0
    }
  }
  dynamic "egress" {
    for_each = local.database_subnet_cidrs
    content {
      rule_no    = 405 + egress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 0
      to_port    = 0
    }
  }
  egress {
    rule_no    = 410
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }
  egress {
    rule_no    = 420
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    rule_no    = 430
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = merge(local.common_tags, { Name = "${local.project_name}-Database-NACL" })
}


# --- NACL DE DESENVOLVIMENTO ---
resource "aws_network_acl" "dev" {
  count      = var.create_dev_subnets
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.dev[*].id

  # --- Inbound ---
  # NOVO: Permite tráfego vindo das sub-redes públicas
  dynamic "ingress" {
    for_each = local.public_subnet_cidrs
    content {
      rule_no    = 110 + ingress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite tráfego vindo das outras sub-redes de Dev
  dynamic "ingress" {
    for_each = local.dev_subnet_cidrs
    content {
      rule_no    = 120 + ingress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite portas efêmeras
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # --- Outbound ---
  # NOVO: Permite tráfego de resposta para as sub-redes públicas
  dynamic "egress" {
    for_each = local.public_subnet_cidrs
    content {
      rule_no    = 400 + egress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite tráfego para as outras sub-redes de Dev
  dynamic "egress" {
    for_each = local.dev_subnet_cidrs
    content {
      rule_no    = 410 + egress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite acesso HTTP/HTTPS de saída
  egress {
    rule_no    = 440
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    rule_no    = 450
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
    egress {
    rule_no    = 460
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  tags = merge(local.common_tags, { Name = "${local.project_name}-Dev-NACL" })
}


# --- NACL DE HOMOLOGAÇÃO ---
resource "aws_network_acl" "hml" {
  count      = var.create_hml_subnets
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.hml[*].id

  # --- Inbound ---
  # NOVO: Permite tráfego vindo das sub-redes públicas
  dynamic "ingress" {
    for_each = local.public_subnet_cidrs
    content {
      rule_no    = 110 + ingress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite tráfego vindo das outras sub-redes de Hml
  dynamic "ingress" {
    for_each = local.hml_subnet_cidrs
    content {
      rule_no    = 120 + ingress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = ingress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite portas efêmeras
  ingress {
    rule_no    = 130
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # --- Outbound ---
  # NOVO: Permite tráfego de resposta para as sub-redes públicas
  dynamic "egress" {
    for_each = local.public_subnet_cidrs
    content {
      rule_no    = 400 + egress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite tráfego para as outras sub-redes de Hml
  dynamic "egress" {
    for_each = local.hml_subnet_cidrs
    content {
      rule_no    = 410 + egress.key
      protocol   = "-1"
      action     = "allow"
      cidr_block = egress.value
      from_port  = 0
      to_port    = 0
    }
  }
  # Permite acesso HTTP/HTTPS de saída
  egress {
    rule_no    = 440
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  egress {
    rule_no    = 450
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
    egress {
    rule_no    = 460
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 32768
    to_port    = 65535
  }

  tags = merge(local.common_tags, { Name = "${local.project_name}-Hml-NACL" })
}