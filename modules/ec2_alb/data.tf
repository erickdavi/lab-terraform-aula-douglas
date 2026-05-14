# modules/ec2_alb/data.tf

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  resolved_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2023.id
}
