import subprocess
import json
import time
import tempfile
import os

# Configuration
PROJECT_ID = os.getenv('GOOGLE_CLOUD_PROJECT')
SERVICE_ACCOUNT_NAME = "dex-storage-service-account"
SERVICE_ACCOUNT_DISPLAY_NAME = "Dex Storage Service Account"
CUSTOM_ROLE_ID = "DexCustomStorageRole"
KEY_FILE_NAME = f"{SERVICE_ACCOUNT_NAME}-key.json"

SERVICE_ACCOUNT_EMAIL = f"{SERVICE_ACCOUNT_NAME}@{PROJECT_ID}.iam.gserviceaccount.com"

# Step 1: Remove IAM policy bindings for predefined roles
print("Removing IAM policy bindings...")

roles = [
    "roles/bigquery.user",
    "roles/bigquery.dataEditor",
    f"projects/{PROJECT_ID}/roles/{CUSTOM_ROLE_ID}"
]

for role in roles:
    try:
        subprocess.run([
            "gcloud", "projects", "remove-iam-policy-binding", PROJECT_ID,
            "--member", f"serviceAccount:{SERVICE_ACCOUNT_EMAIL}",
            "--role", role,
            "--quiet"
        ], check=True)
        print(f"Removed role: {role}")
    except subprocess.CalledProcessError as e:
        print(f"Failed to remove role {role}: {e}")

# Step 2: Delete custom IAM role
print("Deleting custom IAM role...")
try:
    subprocess.run([
        "gcloud", "iam", "roles", "delete", CUSTOM_ROLE_ID,
        "--project", PROJECT_ID,
        "--quiet"
    ], check=True)
    print("Custom role deleted successfully.")
except subprocess.CalledProcessError as e:
    print(f"Failed to delete custom role: {e}")

# Step 3: Delete the service account
print("Deleting service account...")
try:
    subprocess.run([
        "gcloud", "iam", "service-accounts", "delete", SERVICE_ACCOUNT_EMAIL,
        "--quiet"
    ], check=True)
    print("Service account deleted successfully.")
except subprocess.CalledProcessError as e:
    print(f"Failed to delete service account: {e}")

print("Teardown completed.")
