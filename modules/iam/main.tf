# modules/iam/main.tf

# =============================================================================
# GRUPO: AulaAdministrador
# Permissão: Acesso administrativo completo à conta AWS
# =============================================================================

resource "aws_iam_group" "administrador" {
  name = "AulaAdministrador"
}

resource "aws_iam_group_policy_attachment" "administrador_full" {
  group      = aws_iam_group.administrador.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# =============================================================================
# GRUPO: AulasomenteLeitura
# Permissão: Leitura de todos os recursos da AWS (sem permissão de escrita)
# =============================================================================

resource "aws_iam_group" "somente_leitura" {
  name = "AulasomenteLeitura"
}

resource "aws_iam_group_policy_attachment" "somente_leitura_readonly" {
  group      = aws_iam_group.somente_leitura.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# =============================================================================
# GRUPO: AulaFinanceiro
# Permissão: Cost Explorer (visualizar custos) + Billing (fatura e pagamentos)
# Obs: Para funcionar, o acesso de usuários IAM ao console de faturamento
#      deve estar habilitado em: Billing > IAM Access
# =============================================================================

resource "aws_iam_group" "financeiro" {
  name = "AulaFinanceiro"
}

# Acesso de leitura à página de Faturamento (Bills)
resource "aws_iam_group_policy_attachment" "financeiro_billing" {
  group      = aws_iam_group.financeiro.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
}

# Acesso ao Cost Explorer (análise de custos e uso)
resource "aws_iam_group_policy" "financeiro_cost_explorer" {
  name  = "AulaFinanceiro-CostExplorer"
  group = aws_iam_group.financeiro.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CostExplorerFullAccess"
        Effect = "Allow"
        Action = [
          "ce:GetCostAndUsage",
          "ce:GetCostAndUsageWithResources",
          "ce:GetCostForecast",
          "ce:GetDimensionValues",
          "ce:GetReservationCoverage",
          "ce:GetReservationPurchaseRecommendation",
          "ce:GetReservationUtilization",
          "ce:GetRightsizingRecommendation",
          "ce:GetSavingsPlansCoverage",
          "ce:GetSavingsPlansUtilization",
          "ce:GetSavingsPlansUtilizationDetails",
          "ce:GetTags",
          "ce:GetUsageForecast",
          "ce:ListCostAllocationTags",
          "ce:ListCostCategoryDefinitions",
          "ce:DescribeCostCategoryDefinition"
        ]
        Resource = "*"
      },
      {
        Sid    = "BudgetsReadAccess"
        Effect = "Allow"
        Action = [
          "budgets:ViewBudget",
          "budgets:DescribeBudgets",
          "budgets:DescribeBudgetPerformanceHistory"
        ]
        Resource = "*"
      }
    ]
  })
}

# =============================================================================
# GRUPO: AulaEC2devs
# Permissão: Acesso completo ao EC2 (instâncias, AMIs, Security Groups, etc.)
# =============================================================================

resource "aws_iam_group" "ec2_devs" {
  name = "AulaEC2devs"
}

resource "aws_iam_group_policy_attachment" "ec2_devs_full" {
  group      = aws_iam_group.ec2_devs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
