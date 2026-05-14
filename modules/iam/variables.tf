# modules/iam/variables.tf

variable "common_tags" {
  description = "Tags comuns aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
