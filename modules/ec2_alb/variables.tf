# modules/ec2_alb/variables.tf

variable "project_name" {
  description = "Nome do projeto usado nas tags e nomes dos recursos."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde os recursos serão criados."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas para o ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas para as instâncias EC2."
  type        = list(string)
}

variable "instance_type" {
  description = "Tipo da instância EC2."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID da instância EC2. Se vazio, usa o Amazon Linux 2023 mais recente."
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Nome do Key Pair para acesso SSH à instância EC2 (opcional)."
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "Caminho HTTP para o health check do Target Group."
  type        = string
  default     = "/"
}

variable "app_port" {
  description = "Porta da aplicação na instância EC2."
  type        = number
  default     = 80
}

variable "common_tags" {
  description = "Tags comuns aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
