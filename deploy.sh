#!/bin/bash

echo "QR Code Generator Installer"

# Check Login
# az configure --defaults output=json
az account show
if [ $? -eq 1 ]; then
  exit 1
fi

# Check Variables
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

# Start

result=$(az group exists --name $RESOURCE_GROUP_NAME)
if [ "${result}" = true ];  then
    echo "Resource Group already exist"
else
    echo "Resouce Group does not exist, and will be created now"
    az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
fi

app_serviceplan_name="asp-$WEB_APP_NAME"

az appservice plan create \
    --name $app_serviceplan_name \
    --resource-group $RESOURCE_GROUP_NAME \
    --sku F1

if [ $? -eq 1 ]; then
  exit 1
fi

az webapp create \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --plan $app_serviceplan_name

if [ $? -eq 1 ]; then
  exit 1
fi

# az webapp up \
#     --plan $app_serviceplan_name \
#     --name $WEB_APP_NAME \
#     --resource-group $RESOURCE_GROUP_NAME \
#     --location $LOCATION \
#     --runtime "PYTHON|3.11"

az webapp deployment source config-local-git \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME

if [ $? -eq 1 ]; then
  exit 1
fi

az webapp deployment source sync \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME

if [ $? -eq 1 ]; then
  exit 1
fi

az webapp config appsettings set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --settings WEBSITE_PYTHON_VERSION=3.9 FLASK_APP=main.py FLASK_ENV=production

if [ $? -eq 1 ]; then
  exit 1
fi

az webapp restart \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME

if [ $? -eq 1 ]; then
  exit 1
fi

az webapp show \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --query defaultHostName \
    --output tsv

if [ $? -eq 1 ]; then
  exit 1
fi
