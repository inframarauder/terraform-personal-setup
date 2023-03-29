# S3 bucket - to store remote state
resource "aws_s3_bucket" "remote_state" {
  bucket_prefix = var.bucket_name_prefix

  tags = {
    "Terraform" = "true"
    "Purpose"   = "Terraform Remote State Storage"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_acl" "remote_state_acl" {
  bucket = aws_s3_bucket.remote_state.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "s3Public_remote_state" {
  depends_on              = [aws_s3_bucket_policy.remote_state]
  bucket                  = aws_s3_bucket.remote_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy
data "aws_iam_policy_document" "bucket_policy_doc" {
  statement {
    sid    = "DenyInsecureAccess"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "${aws_s3_bucket.remote_state.arn}",
      "${aws_s3_bucket.remote_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  statement {
    sid    = "EnforceEncryptedAccess"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.remote_state.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }
  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.remote_state.arn}/*"
    ]
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }
}

resource "aws_s3_bucket_policy" "remote_state" {
  bucket = aws_s3_bucket.remote_state.id
  policy = data.aws_iam_policy_document.bucket_policy_doc.json
}

# DynamoDB table - to store remote state lock
resource "aws_dynamodb_table" "lock_table" {
  name           = "${var.bucket_name}-lock-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  tags = {
    Terraform = "true"
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
