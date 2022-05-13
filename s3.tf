resource "aws_s3_bucket" "primary" {
  bucket        = "aws-poc-s3-primary"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
  replication_configuration {
    role = aws_iam_role.replication.arn
    rules {
      id     = "replication"
      status = "Enabled"

      destination {
        bucket        = aws_s3_bucket.failover.arn
        storage_class = "STANDARD"
      }
    }
  }
  tags = {
    Project = "aws-poc"
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "primary" {
  bucket = aws_s3_bucket.primary.bucket
  name   = "primary-deep-archive"
  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}

resource "aws_s3_bucket" "failover" {
  bucket        = "aws-poc-s3-failover"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
  tags = {
    Project = "aws-poc"
  }
  provider = aws.sydney
}

resource "aws_s3_bucket_object" "primary" {
  bucket       = aws_s3_bucket.primary.id
  key          = "design.svg"
  source       = "./docker/design_cdn.svg"
  content_type = "image/svg+xml"
  etag         = filemd5("./docker/design_cdn.svg")
}

resource "aws_s3_bucket_public_access_block" "primary" {
  bucket                  = aws_s3_bucket.primary.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_public_access_block" "failover" {
  bucket                  = aws_s3_bucket.failover.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  provider                = aws.sydney
}

data "aws_iam_policy_document" "primary" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.primary.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

data "aws_iam_policy_document" "failover" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.failover.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
  provider = aws.sydney
}

resource "aws_s3_bucket_policy" "primary" {
  bucket = aws_s3_bucket.primary.id
  policy = data.aws_iam_policy_document.primary.json
}

resource "aws_s3_bucket_policy" "failover" {
  bucket   = aws_s3_bucket.failover.id
  policy   = data.aws_iam_policy_document.failover.json
  provider = aws.sydney
}

resource "aws_s3_bucket_policy" "block_bucket_delete" {
  bucket   = aws_s3_bucket.failover.id
  policy   = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:DeleteBucket"
      ],
      "Effect": "Deny",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.failover.id}",
      "Principal": {
        "AWS": ["*"]
      }
    }
  ]
}
POLICY
  provider = aws.sydney
}

resource "aws_iam_role" "replication" {
  name_prefix = "replication"
  description = "Allow S3 to assume the role for replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "s3ReplicationAssume",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name_prefix = "replication"
  description = "Allows reading for replication."
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObjectVersionForReplication",
                "s3:GetObjectVersionAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.primary.id}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetReplicationConfiguration"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.primary.id}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ReplicateObject",
                "s3:ReplicateDelete",
                "s3:ReplicateTags",
                "s3:GetObjectVersionTagging"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.failover.id}/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}
