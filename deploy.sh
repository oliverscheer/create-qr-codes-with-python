#!/bin/bash


export RESOURCE_GROUP_NAME=rg-test-1
export LOCATION=westeurope
export WEB_APP_NAME=oscheertestqrcode2
export SKU=B1

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

# Start

echo "Checking if Resource Group exists"
result=$(az group exists --name $RESOURCE_GROUP_NAME)
if [ "${result}" = true ];  then
    echo "Resource Group already exist"
else
    echo "Resouce Group does not exist, and will be created now"
    az group create --name $RESOURCE_GROUP_NAME --location $LOCATION
fi

APP_SERVICE_PLAN="asp-$WEB_APP_NAME"

echo "Creating App Service Plan"
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

echo "Creating Web App up"
az webapp up \
    --plan $APP_SERVICE_PLAN \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --location $LOCATION \
    --runtime "PYTHON|3.11"

echo "Update startup command"
az webapp config set \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $WEB_APP_NAME \
    --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 main:app"

echo "Configuring Web App"
az webapp config appsettings set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --settings WEBSITE_PYTHON_VERSION=3.11 FLASK_APP=main.py FLASK_ENV=production

# echo "Configuring Web App"
# az webapp config appsettings set \
#     --name $WEB_APP_NAME \
#     --resource-group $RESOURCE_GROUP_NAME \
#     --settings SCM_DO_BUILD_DURING_DEPLOYMENT=true

if [ $? -eq 1 ]; then
  exit 1
fi

echo "Restarting Web App"
az webapp restart \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME

if [ $? -eq 1 ]; then
  exit 1
fi

echo "Getting Web App URL"
WEB_APP_URL=$(az webapp show \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --query defaultHostName \
    --output tsv)
echo $WEB_APP_URL

if [ $? -eq 1 ]; then
  exit 1
fi

echo "Web app installed successful: $WEB_APP_URL"

# destroy everything
# az group delete --name $RESOURCE_GROUP_NAME --yes --no-wait