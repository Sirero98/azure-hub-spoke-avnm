#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------
# Bootstrap del backend remoto de Terraform
# Crea el RG, el Storage Account y el contenedor donde se guardará
# el state. Es idempotente: se puede ejecutar varias veces.
# ------------------------------------------------------------------

# Variables
RESOURCE_GROUP="rg-tfstate"
LOCATION="westeurope"
STORAGE_ACCOUNT_NAME="sttfstatejm2026"
SKU="Standard_LRS"
CONTAINER_NAME="tfstate"
RETENTION_DAYS=30

# 1. Grupo de recursos
echo "==> Creando grupo de recursos '$RESOURCE_GROUP'..."
az group create \
  --name "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --output none

# 2. Storage Account (se reutiliza si ya existe en este RG)
echo "==> Comprobando Storage Account '$STORAGE_ACCOUNT_NAME'..."
if az storage account show \
     --name "$STORAGE_ACCOUNT_NAME" \
     --resource-group "$RESOURCE_GROUP" &>/dev/null; then
  echo "    Ya existe en $RESOURCE_GROUP. Se reutiliza."
else
  AVAILABLE=$(az storage account check-name \
    --name "$STORAGE_ACCOUNT_NAME" \
    --query nameAvailable \
    --output tsv)

  if [ "$AVAILABLE" != "true" ]; then
    echo "    ERROR: el nombre '$STORAGE_ACCOUNT_NAME' lo usa otra cuenta de Azure. Elige otro."
    exit 1
  fi

  echo "    Creando Storage Account..."
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

# 3. Versionado y soft delete de blobs
echo "==> Activando versionado y soft delete ($RETENTION_DAYS días)..."
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --enable-delete-retention true \
  --delete-retention-days "$RETENTION_DAYS" \
  --output none

# 4. Rol de datos para el usuario actual (necesario para acceder con Entra ID)
echo "==> Asignando 'Storage Blob Data Contributor' al usuario actual..."
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

echo "    Esperando 60 s a que el rol se propague..."
sleep 60

# 5. Contenedor del state
echo "==> Creando contenedor '$CONTAINER_NAME'..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --auth-mode login \
  --output none

echo ""
echo "Backend listo."
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
echo "  storage_account_name = \"$STORAGE_ACCOUNT_NAME\""
echo "  container_name       = \"$CONTAINER_NAME\""