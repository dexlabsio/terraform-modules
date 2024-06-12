variable athena_results_bucket_name {
  description = "The S3 bucket name for Athena results"
  type = string
}

variable dex_lakehouse_bucket_name {
  description = "The S3 bucket name for the data lakehouse"
  type = string
}

variable region_of_choice {
  description = "The AWS region where the resources will be deployed"
  type = string
}

variable aws_account_id {
  description = "The AWS account ID where the resources are deployed"
  type = string
}

variable dex_user_name {
  description = "The name of the IAM user to create for deX"
  type = string
}
