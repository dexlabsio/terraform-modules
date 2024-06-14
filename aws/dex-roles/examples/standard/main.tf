resource "random_integer" "bucket_suffix" {
  min = 10000000
  max = 99999999
}

resource "aws_s3_bucket" "athena_results" {
  bucket = "my-athena-results-bucket-${random_integer.bucket_suffix.result}"
  acl    = "private"

  tags = {
    Name        = "My Athena Results Bucket"
    Environment = "Example"
  }
}

resource "aws_s3_bucket" "dex_lakehouse" {
  bucket = "my-dex-lakehouse-bucket-${random_integer.bucket_suffix.result}"
  acl    = "private"

  tags = {
    Name        = "My Dex Lakehouse Bucket"
    Environment = "Example"
  }
}

module "dex_roles" {
  source                = "../.."

  athena_results_bucket_name = aws_s3_bucket.athena_results.id
  dex_lakehouse_bucket_name  = aws_s3_bucket.dex_lakehouse.id
  region_of_choice           = "us-east-1"
  aws_account_id             = "0987654321"
  dex_external_identity_arn = "arn:aws:iam::1234567890:role/ExternalIdentity"
}
