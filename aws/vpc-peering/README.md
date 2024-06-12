# deX VPC Peering Terraform Module

## Overview
This module automates the acceptance of a VPC peering connection and the
configuration of routing and security settings in AWS. It is designed to
assist customers of deX in setting up a secure network link to access
deX's ingestion services.

## Features
- Accepts an existing VPC peering connection.
- Configures route tables to route traffic via the peered VPC.
- Adds configurable ingress rules to specified security groups.

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
  source                = "https://github.com/dexlabsio/terraform-modules.git//aws/vpc-peering"

  peering_connection_id = "pcx-0example12345"
  peer_cidr_block       = "172.16.10.0/24"  // we'll provide this information
  route_table_ids       = ["rtb-0123456789abcdef0"]
  security_group_rules  = [
    {
      from_port         = 80,
      to_port           = 80,
      protocol          = "tcp",
      security_group_id = "sg-abcdef123456"
    }
  ]
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

| Name                  | Description                                                           | Type  |
|-----------------------|-----------------------------------------------------------------------|-------|
| `peering_connection_id` | The ID of the VPC peering connection to be accepted.                 | `string` |
| `peer_cidr_block`     | The CIDR block of the peer VPC.                                       | `string` |
| `route_table_ids`     | A list of route table IDs to which peering routes will be added.      | `list(string)` |
| `security_group_rules`| A list of objects defining the security group rules for ingress, including ports, protocol, and the security group ID. | `list(object)` |

#### Security Group Rules Details

| Attribute           | Description                                     | Type      |
|---------------------|-------------------------------------------------|-----------|
| `from_port`         | The starting port number for the ingress rule.  | `number`  |
| `to_port`           | The ending port number for the ingress rule.    | `number`  |
| `protocol`          | The protocol type (e.g., `tcp`, `udp`, `icmp`). | `string`  |
| `security_group_id` | The ID of the security group to which the rule will be applied. | `string`  |

## Outputs

| Name                 | Description |
|----------------------|-------------|
| `peering_connection_id` | Outputs the ID of the accepted VPC peering connection. |
| `route_table_ids`    | Outputs the IDs of the route tables updated with peering routes. |
| `security_group_ids` | Outputs the IDs of the security groups with added ingress rules. |

## Examples

Refer to the [examples](./examples) directory for detailed examples on how to use this module in different scenarios.

## Support

For support or inquiries, please contact deX at [support@dexlabs.io](mailto:support@dexlabs.io).
