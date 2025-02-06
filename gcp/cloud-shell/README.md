# Cloud Shell Module for Google Service Account Setup

## Description

This repository provides Python scripts to automate the setup and teardown of a Google Cloud Service Account. The service account is configured with the necessary permissions to manipulate Google Cloud Storage and BigQuery resources.

## Introduction

This module is intended for public use, allowing customers to easily set up and manage a Google Service Account directly from Google Cloud Shell. Customers will follow these steps to configure their environment:

1. Access Google Cloud Shell using their Google Cloud account.
2. Download the provided setup scripts from this repository.
3. Execute the scripts within the Cloud Shell environment.

Upon successful execution, customers will have a fully configured Service Account along with an associated JSON key file. This key file can then be provided to the Dex platform during the setup phase.

## Permissions

Running the setup and teardown scripts requires the following permissions:

```
iam.roles.create
iam.roles.get
iam.roles.list
iam.roles.update
iam.serviceAccountKeys.create
iam.serviceAccountKeys.list
iam.serviceAccounts.create
iam.serviceAccounts.get
iam.serviceAccounts.list
resourcemanager.projects.get
resourcemanager.projects.getIamPolicy
resourcemanager.projects.setIamPolicy
```

---

## Setting up the resources

Follow these steps to set up your Google Cloud Service Account:

1. **Go to Cloud Shell:**  
   Open [Google Cloud Shell](https://shell.cloud.google.com/) in your web browser.

2. **Download the setup script:**  
   Run the following command to download the setup script:
   ```sh
   wget https://raw.githubusercontent.com/dexlabsio/terraform-modules/refs/heads/main/gcp/cloud-shell/bigquery-service-account-setup.py
   ```

3. **Run the setup script:**  
   Execute the script to create the required resources:
   ```sh
   python3 bigquery-service-account-setup.py

4. **Store the generate Service Account Key JSON:**
   The generated service account Key Json will be printed to the terminal output. Store it in a safe place.

---

## Deleting the resources

Follow these steps to remove the Google Cloud Service Account and its associated resources:

1. **Go to Cloud Shell:**  
   Open [Google Cloud Shell](https://shell.cloud.google.com/) in your web browser.

2. **Download the teardown script:**  
   Run the following command to download the teardown script:
   ```sh
   wget https://raw.githubusercontent.com/dexlabsio/terraform-modules/refs/heads/main/gcp/cloud-shell/bigquery-service-account-teardown.py
   ```

3. **Run the teardown script:**  
   Execute the script to delete the created resources:
   ```sh
   python3 bigquery-service-account-teardown.py
   ```

---

## Notes
- Ensure that you have the necessary permissions to create and delete service accounts in your Google Cloud project.
- The JSON key file generated during the setup phase should be securely stored and provided during the Dex platform setup.
- Running the teardown script will permanently remove the service account and its permissions.

---

For any issues or questions, please reach out via the repository's [issues page](https://github.com/dexlabsio/terraform-modules/issues).
