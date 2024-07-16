provider "aws" {
  region = "us-east-1" # CHANGE ME
}

terraform {
  ## (Advanced and optional) Use this if you want to keep an s3 tfstate
  # backend "s3" {
  #   bucket  = "dexlabs-tf-state-store-customerx" # CHANGE ME
  #   key  = "terraform/state/dex/default.tfstate"
  #   region = "us-east-1"
  # }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }
  }
}