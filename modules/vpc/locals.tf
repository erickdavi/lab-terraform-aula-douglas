# vpc/locals.tf

locals {
  # --- LÓGICA DE CÁLCULO DE IP ---
  base_parts  = split(".", var.vpc_base_ip)
  base_prefix = "${local.base_parts[0]}.${local.base_parts[1]}"

  public_subnet_cidrs = [
    for i in range(var.availability_zones_count) : format("%s.%s.0/23", local.base_prefix, i * 10)
  ]
  production_subnet_cidrs = [
    for i in range(var.availability_zones_count) : format("%s.%s.0/23", local.base_prefix, 2 + (i * 10))
  ]
  database_subnet_cidrs = [
    for i in range(var.availability_zones_count) : format("%s.%s.0/23", local.base_prefix, 4 + (i * 10))
  ]
  dev_subnet_cidrs = [
    for i in range(var.availability_zones_count) : format("%s.%s.0/23", local.base_prefix, 6 + (i * 10))
  ]
  hml_subnet_cidrs = [
    for i in range(var.availability_zones_count) : format("%s.%s.0/23", local.base_prefix, 8 + (i * 10))
  ]

  vpc_cidr_block = format("%s.0.0/16", local.base_prefix)

  # --- LÓGICA DE TAGS PADRONIZADAS ---
  project_name = var.project_name
  common_tags = {
    Project   = local.project_name
    ImplementedBy = "Terraform"
  }
}