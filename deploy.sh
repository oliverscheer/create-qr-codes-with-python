#!/bin/bash

APP_SERVICE_PLAN=asp-$WEB_APP_NAME

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