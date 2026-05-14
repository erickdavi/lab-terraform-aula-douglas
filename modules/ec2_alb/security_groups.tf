# modules/ec2_alb/security_groups.tf

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-ALB-SG"
  description = "Permite trafego HTTP e HTTPS da internet para o ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP da internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS da internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ALB-SG"
  })
}

resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-EC2-SG"
  description = "Permite trafego apenas originado do ALB para as instancias EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Trafego da aplicacao vindo do ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-EC2-SG"
  })
}
