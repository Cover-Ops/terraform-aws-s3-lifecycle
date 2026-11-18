# Lifecycle rules on a startup's assets bucket in Hyderabad.
# The bucket is made here only so the example runs on its own: point bucket_names at your own buckets.
locals {
  project     = "acme"
  environment = "production"
  owner       = "platform@acme.example"
}

provider "aws" {
  region = "ap-south-2"

  default_tags {
    tags = {
      Project     = local.project
      Environment = local.environment
      Owner       = local.owner
      CostCentre  = "engineering"
      ManagedBy   = "terraform"
    }
  }
}

data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "aws_s3_bucket" "assets" {
  bucket        = "${local.project}-assets-${data.aws_caller_identity.this.account_id}-${data.aws_region.this.region}"
  force_destroy = true # example only: lets `terraform destroy` remove it with objects inside
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

module "s3_lifecycle" {
  source = "../.."
  # After publishing: source = "github.com/Cover-Ops/terraform-aws-s3-lifecycle?ref=v0.1.0"

  project         = local.project
  environment     = local.environment
  owner           = local.owner
  bucket_names    = [aws_s3_bucket.assets.bucket]
  expire_prefixes = { "tmp/" = 7 }

  depends_on = [aws_s3_bucket_versioning.assets]
}
