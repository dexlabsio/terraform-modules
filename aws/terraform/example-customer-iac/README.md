# Example deX AWS Customer Setup

This repository contains essential Terraform scripts for setting up the
necessary AWS resources to integrate with the deX platform. It
automates the creation of access rules, resources, and assets to ensure
that your cloud infrastructure is ready for integration with the deX
stack running on our cloud.

## What This Repository Does

- **Creates Access Rules:** Configures IAM roles and policies for secure access and management.
- **Provisions Resources:** Sets up AWS services like S3, Athena, and Glue required for deX integration.
- **Automates Setup:** Uses Terraform to automate the entire infrastructure setup process.

## How to Use

1. **Clone this Repository:**
   ```bash
   git clone https://github.com/dexlabsio/terraform-modules.git
   cd example-customer-iac-setup-aws
   ```

2. **Configure Terraform:**
   Edit the `aws/example-customer-iac/backend.tf` and `aws/example-customer-iac/permissions.tf` files with your specific AWS configurations.

3. **Initialize and Apply Terraform:**
   ```bash
   terraform init
   terraform apply
   ```

4. **Send Outputs to deX:**
   After running Terraform, send the output variables `cross_account_access_role_arn`, `cross_account_access_role_name`, and `cross_account_id` to the deX team for further integration.

## Prerequisites

- AWS CLI v2: [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Terraform: [Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

## Support

If you need assistance, please contact the deX support team at support@dexlabs.io.