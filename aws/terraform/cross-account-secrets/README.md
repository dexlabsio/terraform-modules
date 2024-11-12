# deX VPC Peering Terraform Module

## Overview
This Terraform module facilitates secure cross-account access to AWS
Secrets Manager secrets. It addresses the necessity of configuring both
resource policies and identity policies to enable users in one AWS
account to access secrets stored in another account. Additionally, it
ensures that the identity has permission to use the associated KMS keys
for decryption, adhering to AWS security best practices. To learn more,
reference: https://docs.aws.amazon.com/secretsmanager/latest/userguide/auth-and-access_examples_cross.html.

## Features
- Dynamic Policy Configuration: Automatically generates and attaches
    policies to secrets and KMS keys based on provided ARNs,
    facilitating easy management of access controls.
- Customizable Variables: Allows specification of secrets ARNs, external
    role ARN, and KMS keys ARNs, offering flexibility in configuring
    access patterns.
- Compliance with AWS Best Practices: Adheres to AWS recommendations for
    securing cross-account access, emphasizing the use of
    customer-managed KMS keys for encryption.

## Prerequisites
- AWS account
- Terraform installed (version 0.12+)
- AWS CLI installed and configured

## Usage
To use this module, include it in your Terraform projects with the
necessary variables. Below is an example of how to call this module in
your Terraform configuration:

```hcl
module "dex_vpc_peering" {
  source                = "https://github.com/dexlabsio/terraform-modules.git//aws/terraform/cross-account-secrets"

  secrets_arn_list = ["arn:aws:secretsmanager:region:source-account-id:secret:secret-name"]
  kms_keys_id_list = ["6aab8134-f139-44f2-88d3-4cd016cdf0ce"]

  // This will be provided by deX
  external_role_arn = "arn:aws:iam::external-account-id:role/external-role"
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

## Variables

| Name                  | Description                                                                                                                                                                                                                   | Type         |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|
| secrets_arn_list      | List of secrets ARN that needs to be shared.                                                                                                                                                                         | list(string) |
| external_role_arn     | Arn for the Dex role accessing the secrets.                                                                                                                                                                        | string      |
| kms_keys_id_list     | The list of KMS ids ARN, this is for allowing dex_external_role to decrypt the secrets. Every secret has an encryption key, make sure to define all of the respective secrets keys here.                        | list(string) |

## Support

For support or inquiries, please contact deX at [support@dexlabs.io](mailto:support@dexlabs.io).
