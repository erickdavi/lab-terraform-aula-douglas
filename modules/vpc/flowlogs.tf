# vpc/flowlogs.tf

# 1. Cria o Log Group no CloudWatch para receber os logs
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.create_flow_logs

  name              = "/aws/vpc-flow-logs/${local.project_name}"
  retention_in_days = 90

  tags = merge(local.common_tags, {
    Name     = "${local.project_name}-flow-logs-group"
    Produto  = "Flowlogs"
    Ambiente = "Infraestrutura"
  })
}


# 2. Cria a Role no IAM que o serviço de Flow Logs usará para escrever no CloudWatch
resource "aws_iam_role" "flow_logs" {
  count = var.create_flow_logs

  name = "${local.project_name}-flow-logs-role"

  # Política de Confiança: Permite que o serviço 'vpc-flow-logs' assuma esta role.
  # Esta parte já estava correta e segue a documentação.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name     = "${local.project_name}-flow-logs-role"
    Produto  = "Flowlogs"
    Ambiente = "Infraestrutura"
  })
}

# 3. [REMOVIDO] O recurso 'aws_iam_role_policy_attachment' foi removido.

# 4. [NOVO] Cria e anexa a política de permissões diretamente na Role.
#    Esta política usa o JSON exato da documentação da AWS que você encontrou.
resource "aws_iam_role_policy" "flow_logs" {
  count = var.create_flow_logs

  name = "${local.project_name}-flow-logs-permissions"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}


# 5. Finalmente, cria o recurso do Flow Log na VPC
resource "aws_flow_log" "main" {
  count = var.create_flow_logs

  iam_role_arn             = aws_iam_role.flow_logs[0].arn
  log_destination          = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type             = "REJECT"
  vpc_id                   = aws_vpc.main.id
  max_aggregation_interval = 60 # 1 minuto

  tags = merge(local.common_tags, {
    Name     = "${local.project_name}-flow-log"
    Produto  = "Flowlogs"
    Ambiente = "Infraestrutura"
  })
}