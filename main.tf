# CoverOps Marketplace kit: S3 lifecycle and tiering.
# Lifecycle rules on the buckets you name: Intelligent-Tiering, old versions deleted, unfinished
# uploads removed, and optional expiry per prefix. Apache 2.0.

locals {
  tags = merge(var.extra_tags, {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    CostCentre  = var.cost_centre
    ManagedBy   = "terraform"
    Kit         = "coverops/aws-s3-lifecycle"
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = toset(var.bucket_names)
  bucket   = each.value

  rule {
    id     = "abort-unfinished-uploads"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_multipart_days
    }
  }

  dynamic "rule" {
    for_each = var.noncurrent_version_days > 0 ? [1] : []
    content {
      id     = "delete-old-versions"
      status = "Enabled"
      filter {}
      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_version_days
      }
    }
  }

  dynamic "rule" {
    for_each = var.intelligent_tiering ? [1] : []
    content {
      id     = "intelligent-tiering"
      status = "Enabled"
      # Objects under 128 KB are not tiered by S3 and carry no monitoring fee, so leave them out.
      filter {
        object_size_greater_than = 131072
      }
      transition {
        days          = 0
        storage_class = "INTELLIGENT_TIERING"
      }
    }
  }

  dynamic "rule" {
    for_each = var.expire_prefixes
    content {
      id     = "expire-${trim(replace(rule.key, "/[^A-Za-z0-9]+/", "-"), "-")}"
      status = "Enabled"
      filter {
        prefix = rule.key
      }
      expiration {
        days = rule.value
      }
    }
  }
}
