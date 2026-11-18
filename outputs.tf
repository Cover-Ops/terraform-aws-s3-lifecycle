output "tags" {
  description = "The mandatory tags. Put them on the buckets too (lifecycle rules themselves carry no tags)."
  value       = local.tags
}

output "bucket_names" {
  description = "The buckets whose lifecycle rules this kit manages."
  value       = sort(keys(aws_s3_bucket_lifecycle_configuration.this))
}
