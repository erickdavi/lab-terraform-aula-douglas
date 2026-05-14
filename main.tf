# main.tf

provider "aws" {
  # Para autenticação, garanta que suas credenciais estejam configuradas
  # no ambiente utilizando "aws configure"
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source                   = "./modules/vpc"
  project_name             = "projeto-aula-5"
  vpc_base_ip              = "10.100.0.0" ## Define o IP base da VPC. O módulo extrairá os dois primeiros octetos (ex: "192.172") para gerar todos os CIDRs da rede. Os octetos finais são ignorados
  availability_zones_count = 3
  create_flow_logs         = 0 ## 0 = desabilitado no AWS Academy (iam:CreateRole bloqueado)
  create_nat_gateway       = 1 ## 1 = CRIAR, 0 = NÃO CRIAR

  # --- CONTROLE AQUI O QUE SERÁ CRIADO (1 = LIGA, 0 = DESLIGA) ---
  create_public_subnets     = 1 # Essencial para o NAT Gateway e acesso externo
  create_production_subnets = 1 # 1 Criar ambiente de Produção                      | 0 Não Criar ambiente de Produção
  create_database_subnets   = 1 # 1 Criar ambiente de Banco de Dados                | 0 Não Criar ambiente de Banco de Dados
  create_dev_subnets        = 1 # 1 Criar ambiente de Desenvolvimento               | 0 Não Criar ambiente de Desenvolvimento
  create_hml_subnets        = 1 # 1 Criar ambiente de Homologação                   | 0 Não Criar ambiente de Homologação
}

module "ec2_alb" {
  source = "./modules/ec2_alb"

  project_name       = "projeto-aula-5"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.production_subnet_ids
  instance_type      = "t3.micro"

  common_tags = {
    Project       = "projeto-aula-5"
    ImplementedBy = "Terraform"
  }
}

module "security" {
  source = "./modules/security"

  project_name = "projeto-aula-5"
  common_tags = {
    Project       = "projeto-aula-5"
    ImplementedBy = "Terraform"
  }
}

# module "iam" desabilitado no AWS Academy (iam:CreateGroup bloqueado pela role voclabs)
# Habilite fora do Academy removendo este comentario e o bloco abaixo:
# module "iam" {
#   source = "./modules/iam"
#   common_tags = {
#     Project       = "projeto-aula-5"
#     ImplementedBy = "Terraform"
#   }
# }

## VPC:              10.100.0.0/16
## Publica:          10.100.0.0/23 (AZ1) | 10.100.10.0/23 (AZ2) | 10.100.20.0/23 (AZ3)
## Produção:         10.100.2.0/23 (AZ1) | 10.100.12.0/23 (AZ2) | 10.100.22.0/23 (AZ3)
## Banco de Dados:   10.100.4.0/23 (AZ1) | 10.100.14.0/23 (AZ2) | 10.100.24.0/23 (AZ3)
## Desenvolvimento:  10.100.6.0/23 (AZ1) | 10.100.16.0/23 (AZ2) | 10.100.26.0/23 (AZ3)
## Homologação:      10.100.8.0/23 (AZ1) | 10.100.18.0/23 (AZ2) | 10.100.28.0/23 (AZ3)
