# Terraform module for configuring SSO in AWS MWAA environments

## Overview

This Terraform module provides a comprehensive solution for integrating
Cognito SSO authentication into the Amazon Managed Workflows for Apache
Airflow (MWAA) user interface. This module not only facilitates secure
and efficient user authentication but also aligns with best practices
for cloud architecture, ensuring a robust, scalable, and secure deployment.

## Features

1. **Domain and SSL Configuration**:
   - Manages Route 53 DNS records and ACM certificates for secure HTTPS
      communication.
   - Utilizes a custom domain configured for the MWAA environment.

2. **Load Balancer Setup**:
   - Configures an Application Load Balancer (ALB) with options for
      internet-facing or internal setups.
   - Uses AWS Cognito for user authentication.
   - Manages access and connection logs in an S3 bucket.

3. **Lambda Integration**:
   - Deploys an AWS Lambda function for authentication requests,
      interfacing with Google's OAuth 2.0 endpoints.
   - Includes IAM roles and policies for secure AWS service interactions.

4. **IAM Configuration**:
   - Provides Role-Based Access Control (RBAC) via IAM roles for
      different user groups.
   - Manages policies allowing Lambda functions to assume roles and
      securely interact with MWAA.

5. **Logging and Monitoring**:
   - Sets up AWS CloudWatch for operational visibility and troubleshooting.

## Prerequisites
- AWS account
- Terraform installed (version 1.0+)
- AWS CLI installed and configured
- **Cognito user pool pre-configured**

## Usage
To use this module, include it in your Terraform project with the
necessary variables. Below is an example of how to call this module in
your Terraform configuration

```hcl
module "mwaa_sso" {
  source = "github.com/dexlabsio/terraform-modules//aws/mwaa-sso?ref=main"

  name                     = "MyCompanyAirflow"
  domain                   = "airflow.mycompany.com" 
  hosted_zone_id           = "Z3M3LMPEXAMPLE"
  mwaa_env_name            = "example"
  mwaa_rbac_role_name      = "Admin"
  mwaa_vpc_id              = "vpc-123456781234"
  mwaa_endpoint_ips        = ["10.0.0.44", "10.0.1.157"]
  public_subnets_ids       = ["subnet-01234567878990000", "subnet-01234567878991111"]
  private_subnets_ids      = ["subnet-01234567878992222", "subnet-01234567878993333"]
  alb_access_mode          = "PUBLIC"
  cognito_context = {
    user_pool_arn          = "arn:aws:cognito-idp:us-east-1:0123456789012:userpool/us-east-1_00991122"
    user_pool_client_id    = "1234567890"
    user_pool_domain       = "mwaa-sso-example"
  }
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


## Variable Descriptions

This section details the variables used in the Terraform module.
Understanding these variables is crucial for correctly configuring the
integration of Google SSO with AWS MWAA.

### Core Configuration Variables

| Name                    | Description                                                      | Type           | Required | Default | Reference                                                                                                      |
|-------------------------|------------------------------------------------------------------|----------------|----------|---------|---------------------------------------------------------------------------------------------------------------|
| `name`                  | This will be appended to the resources to contextualize the resources. | `string`       | Yes      |         |                                                                                                               |
| `domain`                | The domain users will use to access the Airflow instance.        | `string`       | Yes      |         |                                                                                                               |
| `hosted_zone_id`        | The Hosted Zone where the domain will be created.                | `string`       | Yes      |         |                                                                                                               |
| `mwaa_env_name`         | Name of the pre-existing MWAA environment.                       | `string`       | Yes      |         |                                                                                                               |
| `mwaa_rbac_role_name`   | The RBAC role to be assumed by the user. Possible values are Public, User, Op, Admin, and Viewer. | `string` | No       | `Viewer` | [Airflow Access Control Documentation](https://airflow.apache.org/docs/apache-airflow-providers-fab/stable/auth-manager/access-control.html#) |
| `mwaa_vpc_id`           | The VPC Id of your existing MWAA environment.                    | `string`       | Yes      |         |                                                                                                               |

## Lambda Configuration Variables

| Name                    | Description                                                      | Type           | Required | Default | Reference                                                                                                      |
|-------------------------|------------------------------------------------------------------|----------------|----------|---------|---------------------------------------------------------------------------------------------------------------|
| `lambda_function_bucket`      | s3 bucket where the lambda function is stored. It should exist in the same region as the lambda function | `string`       | Yes      |         |                                                                                                               |
| `lambda_function_object_key`  | The relative path of the .zip function within this bucket.        | `string`       | Yes      |         |                                                                                                               |


### Network Configuration Variables

| Name                    | Description                                                                                   | Type           | Required | Default | Reference |
|-------------------------|-----------------------------------------------------------------------------------------------|----------------|----------|---------|-----------|
| `public_subnets_ids`    | A list of at least two Subnet IDs from your VPC, each residing in different AWS availability zones. The Subnet IDs must correspond to public subnets if you set `InternetFacing` to true, otherwise, they should be for private subnets. | `list(string)` | Yes      |         |           |
| `private_subnets_ids`   | A list of private Subnet IDs used to deploy the authentication lambda. You must specify at least two Subnet IDs. | `list(string)` | Yes      |         |           |
| `alb_access_mode`       | Should the load balancer be internet-facing (public) or private? Accepted values are PUBLIC and PRIVATE. Defaults to PRIVATE. | `string`       | No       | `PRIVATE` |           |
| `alb_session_cookie_name` | The name of the session cookie used by the Load Balancer.                                     | `string`       | No       | `MWAASSOAuthSessionCookie` |           |
| `mwaa_endpoint_ips`     | List of IP addresses for the MWAA endpoints.                                                   | `list(string)` | Yes      |         |           |

### Authentication Context Variables

| Name              | Description                                    | Type   | Required | Default | Reference |
|-------------------|------------------------------------------------|--------|----------|---------|-----------|
| `cognito_context` | OIDC Cognito context for handling user authentication. Contains: `user_pool_arn`, `user_pool_client_id`, `user_pool_domain` | `object` | Yes      |         |           |
