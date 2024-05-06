# deX Public Terraform Modules

Welcome to the deX Public Terraform Modules repository! This repository
contains reusable Terraform modules designed to assist customers in
setting up dex-related resources on various cloud platforms. These
modules are aimed at simplifying the deployment process and ensuring
consistency across different cloud environments.

## Modules

### AWS

- [VPC Peering](aws/vpc-peering): This module facilitates the acceptance
    of pre-created dex VPC peering requests on AWS. It includes
    additional configurations to generate the required resources for
    allowing traffic flow between the connected VPCs.

### GCP

_(Under Construction)_

### Azure

_(Under Construction)_

## Getting Started

To begin using the modules, follow these steps:

1. Clone this repository to your local machine:

```bash
git clone https://github.com/dexlabsio/terraform-modules.git
```

2. Navigate to the desired cloud platform folder (`aws`, `gcp`, or
    `azure`).

3. Explore the available modules and choose the one that fits your
    requirements.

4. Refer to the module's documentation for detailed usage instructions,
    input variables, and outputs.

### Usage Example

Below is an example of how you can use our modules:

```hcl
module "dex_example" {
  source = "git::https://github.com/dexlabsio/terraform-modules.git//<cloud>/<module>"  
  // Customize input variables as needed
}
```

Replace the input variables with appropriate values based on your
environment and requirements.

## Contributing

We welcome contributions from the community to enhance and expand the
functionality of these modules. If you have ideas for new modules or
improvements to existing ones, feel free to submit a pull request or open
an issue on GitHub.

## Feedback

Your feedback is valuable to us! If you encounter any issues, have
questions, or would like to request new features, please don't
hesitate to reach out to us via GitHub issues.

## License

This project is licensed under the [MIT License](LICENSE).

---
© 2024 deX Labs. All rights reserved.
