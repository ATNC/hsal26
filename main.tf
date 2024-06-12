provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "immutable_bucket" {
  bucket = "immutable-bucket"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.immutable_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "log-bucket-for-immutable-bucket"

  acl = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket = aws_s3_bucket.immutable_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.immutable_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDeleteObject",
      "Effect": "Deny",
      "Principal": "*",
      "Action": [
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::immutable-bucket/*"
      ]
    }
  ]
}
POLICY
}

output "bucket_id" {
  value = aws_s3_bucket.immutable_bucket.id
}

output "log_bucket_id" {
  value = aws_s3_bucket.log_bucket.id
}