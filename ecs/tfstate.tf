# Terraform Remote State
## Backend set in main.tf

variable "infra_tfstate" { default = "terraform-tfstate" }

resource "aws_s3_bucket" "tfstate" {
  bucket = var.infra_tfstate

  tags = {
    Name        = var.infra_tfstate
    Environment = var.infra_env
  }

  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration
    ]
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "tfstate" {
  name         = var.infra_tfstate
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  lifecycle {
    prevent_destroy = true
  }
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = var.infra_tfstate
    Environment = var.infra_env
  }
}
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "tfstate" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.bucket
  lifecycle {
    prevent_destroy = true
  }
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstate.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
