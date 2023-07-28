variable "s3_bucket" {
  description = "s3 bucket name"
  type        = list
  default     = ["wellness-360-tfstate"]
}

variable "s3_acl" {
  description = "s3 bucket acl"
  type        = string
  default     = "private"
}

variable "s3_bucket_versioning" {
  description = "s3 bucket name"
  type        = string
  default     = "Enabled"
}

variable "s3_bucket_block_acl" {
  description = "s3 bucket public acl"
  type        = bool
  default     = true
}

variable "s3_bucket_block_public_policy" {
  description = "s3 bucket block public policy"
  type        = bool
  default     = true
}

variable "s3_bucket_block_public_acls" {
  description = "s3 bucket block public acl"
  type        = bool
  default     = true
}

variable "s3_bucket_restrict" {
  description = "s3 bucket public restirct"
  type        = bool
  default     = true
}
