variable athena_results_bucket_name {
  description = "The S3 bucket name for Athena results"
  type = string
}

variable dex_lakehouse_bucket_name {
  description = "The S3 bucket name for the data lakehouse"
  type = string
}

variable dex_external_identity_arn {
  description = "The ARN of an external IAM identity that belongs to deX's cloud and will be provided by deX to the customers"
  type = string
}
