# vpc/variables.tf

variable "project_name" {
  description = "Nome do projeto para ser usado nas tags dos recursos."
  type        = string
}

variable "vpc_base_ip" {
  description = "O IP base para a VPC (ex: '10.0.0.0'). Usado para gerar os CIDRs das sub-redes."
  type        = string
}

variable "availability_zones_count" {
  description = "Número de zonas de disponibilidade a serem usadas."
  type        = number
  default     = 3
}

# --- INTERRUPTORES CONDICIONAIS ---

variable "create_public_subnets" {
  description = "Coloque 1 para criar as sub-redes Públicas ou 0 para pular."
  type        = number
  default     = 1
  validation {
    condition     = contains([0, 1], var.create_public_subnets)
    error_message = "O valor deve ser 0 ou 1."
  }
}

variable "create_production_subnets" {
  description = "Coloque 1 para criar as sub-redes de Produção ou 0 para pular."
  type        = number
  default     = 1
  validation {
    condition     = contains([0, 1], var.create_production_subnets)
    error_message = "O valor deve ser 0 ou 1."
  }
}

variable "create_database_subnets" {
  description = "Coloque 1 para criar as sub-redes de Banco de Dados ou 0 para pular."
  type        = number
  default     = 1
  validation {
    condition     = contains([0, 1], var.create_database_subnets)
    error_message = "O valor deve ser 0 ou 1."
  }
}

variable "create_dev_subnets" {
  description = "Coloque 1 para criar as sub-redes de Desenvolvimento ou 0 para pular."
  type        = number
  default     = 0
  validation {
    condition     = contains([0, 1], var.create_dev_subnets)
    error_message = "O valor deve ser 0 ou 1."
  }
}

variable "create_hml_subnets" {
  description = "Coloque 1 para criar as sub-redes de Homologação ou 0 para pular."
  type        = number
  default     = 0
  validation {
    condition     = contains([0, 1], var.create_hml_subnets)
    error_message = "O valor deve ser 0 ou 1."
  }
}


variable "create_flow_logs" {
  description = "Coloque 1 para criar o VPC Flow Logs ou 0 para pular."
  type        = number
  default     = 1 # Por padrão, vamos criar
  validation {
    condition     = contains([0, 1], var.create_flow_logs)
    error_message = "O valor deve ser 0 ou 1."
  }
}

variable "create_nat_gateway" {
  type        = number
  default     = 1
  description = "Define se o NAT Gateway será criado (1) ou não (0)"
}
