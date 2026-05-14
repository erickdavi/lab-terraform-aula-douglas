# vpc/vpc.tf
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-VPC"
  })
}