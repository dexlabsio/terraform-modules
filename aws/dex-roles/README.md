# Terraform Module for AWS Athena and S3 Access Setup

## Overview

This Terraform module is designed to simplify the setup of AWS resources needed to work efficiently with AWS Athena and S3 in a DeX partners' AWS environments. It automates the creation of necessary IAM roles and policies, that grant the required permissions for DeX to handle Athena queries and manage data in specified S3 buckets. This module is ideal for partners who need to grant for DeX controlled access to their Athena environment and associated data resources.

## Features

The module configures the following resources:

- **IAM Roles**: Two IAM roles are created:
  - `DeXAthenaSparkRole`: This role is tailored for interacting with AWS Athena and associated S3 buckets for storing query results and other data interactions.
  - `DeXGlueCrawlerRole`: This role is designed for AWS Glue operations, allowing for data cataloging and ETL operations.

- **IAM Policies**: Inline policies attached to the aforementioned roles, granting permissions necessary for operations in Athena, Glue, and S3.

- **IAM User**: A dedicated IAM user is created with permissions to pass the roles and perform direct operations on S3 and Athena, ensuring that the user can manage resources effectively.

## Resources Created

- Two IAM roles with extensive permissions to interact with Athena, Glue, and S3.
- An IAM user with a comprehensive policy that includes permissions for IAM operations, S3 bucket access, and Athena workgroup management.
- Inline policies that outline specific access rights to Athena, Glue, and S3, including logging and monitoring permissions.

## Variables

| Variable                     | Description                                                                                          |
|------------------------------|------------------------------------------------------------------------------------------------------|
| `athena_results_bucket_name` | Specifies the S3 bucket used to store query results from Athena. This bucket is central to managing the output of data analytics operations. |
| `dex_lakehouse_bucket_name`  | Defines the S3 bucket intended for use as a data lakehouse. This bucket stores structured and semi-structured data for analytics and business intelligence operations. |
| `region_of_choice`           | Determines the AWS region where the resources will be deployed. It is critical to set this to the region where the Athena services and S3 buckets are located to minimize latency and ensure compliance with data residency requirements. |
| `aws_account_id`             | The AWS account ID where the resources are to be deployed. This is essential for constructing ARNs and ensuring that the resources are created under the correct AWS account. |
| `dex_user_name`              | The name of the IAM user to be created. This user will be equipped with the necessary permissions to manage and operate the Athena and S3 setups efficiently. |


## Usage

To use this module, include it in your Terraform configurations and provide the required variable inputs. An example usage is as follows:

```hcl
module "dex_roles_setup" {
  source                     = "https://github.com/dexlabsio/terraform-modules.git//aws/dex-roles"

  athena_results_bucket_name = "my-athena-results-bucket"
  dex_lakehouse_bucket_name  = "my-dex-lakehouse-bucket"
  region_of_choice           = "us-east-1"
  aws_account_id             = "123456789012"
  dex_user_name              = "dexUser"
}

```

Initialize the module using:

```bash
terraform init
```

Apply the configuration using:

```bash
terraform apply
```

