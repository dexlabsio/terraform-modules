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

def run_command(command, check=False):
    """ Run a gcloud command and return its output or handle failure. """
    try:
        result = subprocess.run(command, check=check, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        if "ALREADY_EXISTS" in e.stderr or "already exists" in e.stderr or "exists" in e.stderr:
            print(f"Skipping step, resource already exists: {' '.join(command)}")
        else:
            print(f"Error executing command: {' '.join(command)}\n{e.stderr}")
            exit(1)

# Step 1: Create the service account (if not exists)
print("Checking if service account exists...")
existing_accounts = run_command(["gcloud", "iam", "service-accounts", "list", "--format=value(email)", "--project", PROJECT_ID])

if SERVICE_ACCOUNT_EMAIL in existing_accounts:
    print("Service account already exists, skipping creation.")
else:
    print("Creating service account...")
    run_command([
        "gcloud", "iam", "service-accounts", "create", SERVICE_ACCOUNT_NAME,
        "--display-name", SERVICE_ACCOUNT_DISPLAY_NAME,
        "--project", PROJECT_ID
    ], check=True)

# Step 2: Assign predefined roles (BigQuery User and Editor)
print("Assigning BigQuery roles...")

roles = [
    "roles/bigquery.user",
    "roles/bigquery.dataEditor"
]

for role in roles:
    print(f"Checking role {role} assignment...")
    policy_check = run_command([
        "gcloud", "projects", "get-iam-policy", PROJECT_ID,
        "--flatten=bindings[].members",
        "--filter", f"bindings.role={role} AND bindings.members=serviceAccount:{SERVICE_ACCOUNT_EMAIL}",
        "--format=value(bindings.members)"
    ])
    
    if policy_check:
        print(f"Role {role} already assigned, skipping.")
    else:
        run_command([
            "gcloud", "projects", "add-iam-policy-binding", PROJECT_ID,
            "--member", f"serviceAccount:{SERVICE_ACCOUNT_EMAIL}",
            "--role", role
        ], check=True)

# Step 3: Define custom storage role permissions
print("Checking if custom storage role exists...")
existing_roles = run_command(["gcloud", "iam", "roles", "list", "--project", PROJECT_ID, "--format=value(name)"])

if f"projects/{PROJECT_ID}/roles/{CUSTOM_ROLE_ID}" in existing_roles:
    print("Custom storage role already exists, skipping creation.")
else:
    print("Creating custom storage role...")
    storage_permissions = [
        "storage.managedFolders.delete",
        "storage.managedFolders.get",
        "storage.managedFolders.list",
        "storage.multipartUploads.abort",
        "storage.multipartUploads.create",
        "storage.multipartUploads.list",
        "storage.multipartUploads.listParts",
        "storage.objects.create",
        "storage.objects.delete",
        "storage.objects.get",
        "storage.objects.list",
        "storage.objects.restore",
        "storage.objects.update",
        "bigquery.datasets.create",
        "bigquery.datasets.get",
        "bigquery.datasets.getIamPolicy",
        "bigquery.jobs.create",
        "bigquery.models.getMetadata",
        "bigquery.models.list",
        "bigquery.routines.get",
        "bigquery.routines.list",
        "bigquery.tables.create",
        "bigquery.tables.get",
        "bigquery.tables.getData",
        "bigquery.tables.getIamPolicy",
        "bigquery.tables.list",
        "bigquery.tables.update",
        "bigquery.tables.updateData",
        "dataplex.projects.search",
        "resourcemanager.projects.get"
    ]

    role_definition = {
        "title": "Custom Storage Role",
        "description": "Custom role for specific storage permissions",
        "stage": "GA",
        "includedPermissions": storage_permissions
    }

    with tempfile.NamedTemporaryFile(delete=False, mode='w', suffix=".json") as temp_file:
        json.dump(role_definition, temp_file, indent=2)
        temp_file_path = temp_file.name

    try:
        run_command([
            "gcloud", "iam", "roles", "create", CUSTOM_ROLE_ID,
            "--project", PROJECT_ID,
            "--file", temp_file_path
        ], check=True)
    finally:
        os.remove(temp_file_path)

# Step 4: Assign custom storage role to the service account
print("Checking custom storage role assignment...")

custom_role_binding_check = run_command([
    "gcloud", "projects", "get-iam-policy", PROJECT_ID,
    "--flatten=bindings[].members",
    "--filter", f"bindings.role=projects/{PROJECT_ID}/roles/{CUSTOM_ROLE_ID} AND bindings.members=serviceAccount:{SERVICE_ACCOUNT_EMAIL}",
    "--format=value(bindings.members)"
])

if custom_role_binding_check:
    print("Custom storage role already assigned, skipping.")
else:
    print("Assigning custom storage role...")
    run_command([
        "gcloud", "projects", "add-iam-policy-binding", PROJECT_ID,
        "--member", f"serviceAccount:{SERVICE_ACCOUNT_EMAIL}",
        "--role", f"projects/{PROJECT_ID}/roles/{CUSTOM_ROLE_ID}"
    ], check=True)

# Step 5: Generate service account key JSON file
print("Checking if service account key exists...")
existing_keys = run_command([
    "gcloud", "iam", "service-accounts", "keys", "list",
    "--iam-account", SERVICE_ACCOUNT_EMAIL,
    "--project", PROJECT_ID,
    "--managed-by", "user",
    "--format=value(name)"
])

if existing_keys:
    print("Deleting existing service account keys...")
    for key in existing_keys.split("\n"):
        run_command([
            "gcloud", "iam", "service-accounts", "keys", "delete", key,
            "--iam-account", SERVICE_ACCOUNT_EMAIL,
            "--project", PROJECT_ID,
            "--quiet"
        ], check=True)

print("Generating new service account key...")
run_command([
    "gcloud", "iam", "service-accounts", "keys", "create", KEY_FILE_NAME,
    "--iam-account", SERVICE_ACCOUNT_EMAIL,
    "--project", PROJECT_ID
], check=True)

# Read and print the key content
with open(KEY_FILE_NAME, 'r') as key_file:
    key_content = json.load(key_file)
    print("\nService Account Key JSON:\n")
    print(json.dumps(key_content, indent=2))

# Optional: Remove the key file after printing
os.remove(KEY_FILE_NAME)

print("Service account key successfully generated!")
