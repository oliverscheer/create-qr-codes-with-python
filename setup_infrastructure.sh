#!/bin/bash

echo "QR Code Generator Installer"

# Check if user is logged in
az account show
if [ $? -eq 1 ]; then
  exit 1
fi

# Check required environment variables
if [ -n "$RESOURCE_GROUP_NAME" ]; then
    echo "RESOURCE_GROUP_NAME: $RESOURCE_GROUP_NAME"
else
    echo "The variable RESOURCE_GROUP_NAME is either not set or empty"
    exit 1
fi

if [ -n "$LOCATION" ]; then
    echo "LOCATION: $LOCATION"
else
    echo "The variable LOCATION is either not set or empty"
    exit 1
fi

if [ -n "$WEB_APP_NAME" ]; then
    echo "WEB_APP_NAME: $WEB_APP_NAME"
else
    echo "The variable WEB_APP_NAME is either not set or empty"
    exit 1
fi

if [ -n "$SKU" ]; then
    echo "SKU: $SKU"
else
    echo "The variable SKU is either not set or empty"
    exit 1
fi

# Start

echo "Checking if Resource Group exists"
result=$(az group exists --name $RESOURCE_GROUP_NAME)
if [ "${result}" = true ]; then
    echo "Resource Group already exist"
else
    echo "Resouce Group does not exist, and will be created now"
    az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
fi

echo "Creating App Service Plan"
APP_SERVICE_PLAN=asp-$WEB_APP_NAME

az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --is-linux \
    --resource-group $RESOURCE_GROUP_NAME \
    --sku $SKU

if [ $? -eq 1 ]; then
  exit 1
fi

echo "Creating Web App create"
az webapp create \
    --name $WEB_APP_NAME \
    --runtime "PYTHON|3.11" \
    --resource-group $RESOURCE_GROUP_NAME \
    --plan $APP_SERVICE_PLAN

if [ $? -eq 1 ]; then
  exit 1
fi

echo "Configuring Web App"
az webapp config appsettings set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

if [ $? -eq 1 ]; then
  exit 1
fi

echo "Create Service Principal"
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SERVICE_PRINCIPAL_NAME=sp-$WEB_APP_NAME

az ad sp create-for-rbac \
    --name $SERVICE_PRINCIPAL_NAME \
    --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME

if [ $? -eq 1 ]; then
  exit 1
fi

exit 0
