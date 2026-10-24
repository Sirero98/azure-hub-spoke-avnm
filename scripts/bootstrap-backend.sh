#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------
# Terraform remote backend bootstrap
# Creates the resource group, storage account and container that
# hold the Terraform state. Idempotent: safe to run more than once.
# ------------------------------------------------------------------

# Variables
RESOURCE_GROUP="rg-tfstate"
LOCATION="westeurope"
STORAGE_ACCOUNT_NAME="sttfstatejm2026"   # must be globally unique: change it before running
SKU="Standard_LRS"
CONTAINER_NAME="tfstate"
RETENTION_DAYS=30

# 1. Resource group
echo "==> Creating resource group '$RESOURCE_GROUP'..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# 2. Storage account (reused if it already exists in this resource group)
echo "==> Checking storage account '$STORAGE_ACCOUNT_NAME'..."
if az storage account show \
     --name "$STORAGE_ACCOUNT_NAME" \
     --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "    Already exists in $RESOURCE_GROUP. Reusing it."
else
  AVAILABLE=$(az storage account check-name \
    --name "$STORAGE_ACCOUNT_NAME" \
    --query nameAvailable \
    --output tsv)

  if [ "$AVAILABLE" != "true" ]; then
    echo "    ERROR: the name '$STORAGE_ACCOUNT_NAME' is already taken in Azure. Choose another one."
    exit 1
  fi

  echo "    Creating storage account..."
  az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku "$SKU" \
    --min-tls-version TLS1_2 \
    --https-only true \
    --allow-blob-public-access false \
    --allow-shared-key-access false \
    --output none
fi

# 3. Blob versioning and soft delete
echo "==> Enabling versioning and soft delete ($RETENTION_DAYS days)..."
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days "$RETENTION_DAYS" \
  --output none

# 4. Data role for the signed-in user (required for Entra ID access)
echo "==> Assigning 'Storage Blob Data Contributor' to the signed-in user..."
USER_ID=$(az ad signed-in-user show --query id --output tsv)
STORAGE_ACCOUNT_ID=$(az storage account show \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query id \
  --output tsv)

az role assignment create \
  --assignee-object-id "$USER_ID" \
  --assignee-principal-type User \
  --role "Storage Blob Data Contributor" \
  --scope "$STORAGE_ACCOUNT_ID" \
  --output none

echo "    Waiting 60 s for the role assignment to propagate..."
sleep 60

# 5. State container
echo "==> Creating container '$CONTAINER_NAME'..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --auth-mode login \
  --output none

echo ""
echo "Backend ready."
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
echo "  storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "  container_name       = \"$CONTAINER_NAME\""