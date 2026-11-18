variable "project" {
  description = "Short name of the product or company, used in names and the Project tag (lowercase, digits, hyphens)."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.project))
    error_message = "Use 2-31 characters: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Which environment the buckets belong to: production, staging or development."
  type        = string
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Use production, staging or development."
  }
}

variable "owner" {
  description = "Who answers for spend on these buckets: a team or a person's email. Goes in the Owner tag."
  type        = string
}

variable "cost_centre" {
  description = "Cost centre or budget line for the CostCentre tag, e.g. engineering."
  type        = string
  default     = "engineering"
}

variable "bucket_names" {
  description = "Buckets to manage. The kit REPLACES any lifecycle rules these buckets already have."
  type        = list(string)
  validation {
    condition     = length(var.bucket_names) > 0
    error_message = "Name at least one bucket."
  }
}

variable "intelligent_tiering" {
  description = "Move objects to S3 Intelligent-Tiering, which lowers the price of objects nobody reads, with no retrieval fee."
  type        = bool
  default     = true
}

variable "noncurrent_version_days" {
  description = "Delete old (noncurrent) object versions this many days after they were replaced. 0 keeps them forever."
  type        = number
  default     = 30
  validation {
    condition     = var.noncurrent_version_days >= 0
    error_message = "Use 0 or more days."
  }
}

variable "abort_multipart_days" {
  description = "Remove unfinished multipart uploads after this many days. They are billed but never show up as objects."
  type        = number
  default     = 7
  validation {
    condition     = var.abort_multipart_days >= 1
    error_message = "Use 1 or more days."
  }
}

variable "expire_prefixes" {
  description = "Delete objects under these prefixes after the given number of days, e.g. { \"tmp/\" = 7, \"logs/\" = 90 }."
  type        = map(number)
  default     = {}
}

variable "extra_tags" {
  description = "More tags for the tags output."
  type        = map(string)
  default     = {}
}
