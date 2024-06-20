# Terraform Module for AWS Athena and S3 Access Setup

## Overview

This Terraform module is designed to simplify the setup of AWS resources needed
for deX platform to access AWS Athena and associated resources within partners'
AWS environments.

It automates the creation of necessary IAM roles and policies, that grant the
required permissions for DeX to handle Athena queries and manage data in
specified S3 buckets.

This module is ideal for partners who need to easily deploy and control how deX
automations access their Athena environment and associated data resources.

## Features

The module configures the following resources:

- **IAM Roles**: Three IAM roles are created:
  - `DeXAutomationRole`: This role is designed for an external deX indentity to assume and control the necessary resources remotely.
  - `DeXAthenaSparkRole`: This role is tailored for interacting with AWS Athena and associated S3 buckets for storing query results and other data interactions.
  - `DeXGlueCrawlerRole`: This role is designed for AWS Glue operations, allowing access to data cataloging and ETL operations.

- **IAM Policies**: Inline policies attached to the aforementioned roles, granting permissions necessary for operations in Athena, Glue, and S3.

- **IAM Assume Role**: Allow a given deX external IAM role to control these roles and perform direct operations on S3 and Athena, ensuring our automations can manage resources effectively.

## Resources Created

- Two IAM roles with extensive permissions to interact with Athena, Glue, and S3.
- Inline policies that outline specific access rights to Athena, Glue, and S3, including logging and monitoring permissions.
- An IAM user with a comprehensive policy that includes permissions for IAM operations, S3 bucket access, and Athena workgroup management.

## Variables

| Variable                         | Description                                                                                          |
|----------------------------------|------------------------------------------------------------------------------------------------------|
| `athena_results_bucket_name`     | Specifies the S3 bucket used to store query results from Athena. This bucket is central to managing the output of data analytics operations. |
| `dex_lakehouse_bucket_name`      | Defines the S3 bucket intended for use as a data lakehouse. This bucket stores structured and semi-structured data for analytics and business intelligence operations. |
| `dex_external_identity_arn`      | The ARN of an external IAM identity that belongs to deX's cloud and will be provided by deX to the customers. |


## Usage

To use this module, include it in your Terraform configurations and provide the required variable inputs. An example usage is as follows:

```hcl
module "dex_roles" {
  source                     = "https://github.com/dexlabsio/terraform-modules.git//aws/dex-roles"

  athena_results_bucket_name = "my-athena-results-bucket"
  dex_lakehouse_bucket_name  = "my-dex-lakehouse-bucket"
  dex_external_identity_arn = "arn:aws:iam::123456789012:group/example"
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

