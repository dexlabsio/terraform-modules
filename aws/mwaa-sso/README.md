# Terraform Module for Integrating Google SSO with AWS MWAA

This Terraform module provides a comprehensive solution for integrating Google account-based SSO authentication into the Amazon Managed Workflows for Apache Airflow (MWAA) user interface. This module not only facilitates secure and efficient user authentication but also aligns with best practices for cloud architecture, ensuring a robust, scalable, and secure deployment.

## Key Features

1. **Domain and SSL Configuration**:
   - Manages Route 53 DNS records and ACM certificates for secure HTTPS communication.
   - Utilizes a custom domain configured for the MWAA environment.

2. **Load Balancer Setup**:
   - Configures an Application Load Balancer (ALB) with options for internet-facing or internal setups.
   - Implements AWS Cognito for user authentication through Google accounts.
   - Manages access and connection logs in an S3 bucket.

3. **Lambda Integration**:
   - Deploys an AWS Lambda function for authentication requests, interfacing with Google's OAuth 2.0 endpoints.
   - Includes IAM roles and policies for secure AWS service interactions.

4. **IAM Configuration**:
   - Provides Role-Based Access Control (RBAC) via IAM roles for different user groups.
   - Manages policies allowing Lambda functions to assume roles and securely interact with MWAA.

5. **Logging and Monitoring**:
   - Sets up AWS CloudWatch for operational visibility and troubleshooting.

## Variable Descriptions

This section details the variables used in the Terraform module. Understanding these variables is crucial for correctly configuring the integration of Google SSO with AWS MWAA.

### Core Configuration Variables

- **`aws_region`**:
  - **Description**: The AWS region where the SSO resources will be deployed.
  - **Type**: `string`
  - **Required**: Yes

- **`aws_account_id`**:
  - **Description**: The AWS account ID where resources will be managed.
  - **Type**: `string`

- **`mwaa_env_name`**:
  - **Description**: The name of the pre-existing MWAA environment.
  - **Type**: `string`

- **`mwaa_rbac_role_name`**:
  - **Description**: The RBAC role to be assumed by the user. Roles include Public, User, Op, Admin, and Viewer.
  - **Type**: `string`
  - **Reference**: [Airflow Access Control Documentation](https://airflow.apache.org/docs/apache-airflow-providers-fab/stable/auth-manager/access-control.html#)

- **`mwaa_vpc_id`**:
  - **Description**: The VPC Id of your existing MWAA environment.
  - **Type**: `string`

### Network Configuration Variables

- **`public_subnets_ids`**:
  - **Description**: Subnet IDs in two different AWS availability zones. These subnets must be public if the Internet-facing option is true, or private otherwise.
  - **Type**: `list(string)`

- **`private_subnets_ids`**:
  - **Description**: Private subnets used to deploy the AuthenticationLambda.
  - **Type**: `list(string)`

- **`alb_internet_facing`**:
  - **Description**: Determines if the Load Balancer should be internet-facing (public). It is set to private by default.
  - **Type**: `bool`
  - **Default**: `false`

- **`alb_session_cookie_name`**:
  - **Description**: The name of the session cookie used by the Load Balancer.
  - **Type**: `string`

- **`mwaa_endpoint_ips`**:
  - **Description**: List of IP addresses for the MWAA endpoints.
  - **Type**: `list(string)`

### Authentication Context Variables

- **`cognito_context`**:
  - **Description**: OIDC Cognito context for handling user authentication.
  - **Type**: `object` containing:
    - `user_pool_arn`
    - `user_pool_client_id`
    - `user_pool_domain`

Each variable is integral to tailoring the Terraform module to specific AWS and organizational configurations, ensuring secure and functional deployment of SSO capabilities within AWS environments.
