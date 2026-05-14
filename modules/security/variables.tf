# modules/security/variables.tf

variable "project_name" {
  description = "Nome do projeto usado nas tags e nomes dos recursos."
  type        = string
}

variable "common_tags" {
  description = "Tags comuns aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}

variable "cloudtrail_s3_days_to_ia" {
  description = "Dias até mover os logs do CloudTrail para S3 Intelligent-Tiering ou IA."
  type        = number
  default     = 90
}

variable "cloudtrail_s3_days_to_glacier" {
  description = "Dias até mover os logs do CloudTrail para Glacier."
  type        = number
  default     = 365
}

variable "config_s3_days_to_expire" {
  description = "Dias até expirar os snapshots do AWS Config no S3."
  type        = number
  default     = 365
}
