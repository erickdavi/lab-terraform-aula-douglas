# modules/security/config.tf
# Nota AWS Academy: IAM Role e Configuration Recorder removidos (iam:CreateRole bloqueado).
# Os buckets S3 sao criados. As Config Rules requerem o recorder ativo - desabilitadas.

# --- BUCKET S3 PARA O AWS CONFIG ---

resource "aws_s3_bucket" "config" {
  bucket        = "${var.project_name}-aws-config-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-AWSConfig-Bucket"
  })
}

resource "aws_s3_bucket_versioning" "config" {
  bucket = aws_s3_bucket.config.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  bucket = aws_s3_bucket.config.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket                  = aws_s3_bucket.config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "config" {
  bucket = aws_s3_bucket.config.id

  rule {
    id     = "expire-old-config-snapshots"
    status = "Enabled"

    filter {}

    expiration {
      days = var.config_s3_days_to_expire
    }
  }
}
