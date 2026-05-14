# modules/ec2_alb/main.tf

# --- TARGET GROUP ---

resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-TG"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-TG"
  })
}

# --- APPLICATION LOAD BALANCER ---

resource "aws_lb" "main" {
  name               = "${var.project_name}-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ALB"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# --- EC2 INSTANCE ---

resource "aws_instance" "main" {
  ami                    = local.resolved_ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = var.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens                 = "required" # IMDSv2 obrigatório
    http_put_response_hop_limit = 1
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-EC2"
  })
}

resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.main.id
  port             = var.app_port
}

# --- AWS WAF v2 ---

resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project_name}-WAF"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Regra 1: Core Rule Set (proteção contra OWASP Top 10)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Regra 2: Inputs maliciosos conhecidos (SQL injection, XSS, etc.)
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # Regra 3: Lista de reputação de IPs da Amazon (botnets, scanners, etc.)
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-IpReputationList"
      sampled_requests_enabled   = true
    }
  }

  # Regra 4: Proteção contra ameaças específicas para Linux
  rule {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-LinuxRuleSet"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-WAF"
    sampled_requests_enabled   = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-WAF"
  })
}

resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = aws_lb.main.arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
