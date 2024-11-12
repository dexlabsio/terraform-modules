resource "random_integer" "bucket_suffix" {
  min = 10000000
  max = 99999999
}

# Athena S3 buckets are only necessary if you don't have
# your athena stack configured. Delete this block if
# you already have this bucket.
resource "aws_s3_bucket" "athena_results" {
  bucket = "my-athena-results-bucket-${random_integer.bucket_suffix.result}"  # CHANGE ME
  acl    = "private"

  tags = {
    Name        = "My Athena results bucket"  # CHANGE ME
    Environment = "Example"  # CHANGE ME
  }
}

# Athena S3 buckets are only necessary if you don't have
# your athena stack configured. Delete this block if
# you already have this bucket.
resource "aws_s3_bucket" "dex_lakehouse" {
  bucket = "my-dex-lakehouse-bucket-${random_integer.bucket_suffix.result}"  # CHANGE ME
  acl    = "private"

  tags = {
    Name        = "My Dex Lakehouse bucket"  # CHANGE ME
    Environment = "Example"                  # CHANGE ME
  }
}

module "dex_roles" {
  source                     = "git::https://github.com/dexlabsio/terraform-modules.git//aws/terraform/dex-roles"

  athena_results_bucket_name = aws_s3_bucket.athena_results.id  # Change this if you already have a bucket for athena results
  dex_lakehouse_bucket_name  = aws_s3_bucket.dex_lakehouse.id   # Change this if you already have a bucket for the dex lakehouse
  dex_external_account_id    = "601697184715"                   # Don't change this
}

output "cross_account_access_role_arn" {
  value = module.dex_roles.cross_account_access_role_arn
}

output "cross_account_access_role_name" {
  value = module.dex_roles.cross_account_access_role_name
}

output "cross_account_id" {
  value = module.dex_roles.cross_account_id
}
