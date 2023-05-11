# Create QR Codes with Python

This sample is about creating QR codes for multiple purposes with Python.

## Development

Open the project in the DevContainer in Visual Studio Code.

## Requirements for deployment

it is required to have a service principial

```bash
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
SERVICE_PRINCIPAL_NAME=sp-ollisqrcode

az ad sp create-for-rbac \
    --name $SERVICE_PRINCIPAL_NAME \
    --role contributor \
    --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME
```

{
  "appId": "78634af7-a595-402a-8c80-f55a54a92610",
  "displayName": "sp-ollisqrcode",
  "password": "66t8Q~XifPXaKS4RbvCKXs7AdYQajz.mgesFLaJE",
  "tenant": "8471c07a-59b5-4fab-8293-f2431b078a0d"
}

{
  "clientId": "78634af7-a595-402a-8c80-f55a54a92610",
  "clientSecret": "66t8Q~XifPXaKS4RbvCKXs7AdYQajz.mgesFLaJE",
  "subscriptionId": "e1dbceec-e5fd-4374-88f6-6cac9f82b14c",
  "tenantId": "8471c07a-59b5-4fab-8293-f2431b078a0d"
}


aus, um einen Service Principal zu erstellen. Ersetzen Sie <SERVICE-PRINCIPAL-NAME> durch einen Namen Ihrer Wahl, <SUBSCRIPTION-ID> durch Ihre Azure-Abonnement-ID und <RESOURCE-GROUP-NAME> durch den Namen der Ressourcengruppe, auf die der Service Principal Zugriff haben soll.
Notieren Sie sich das appId, tenant, password und subscriptionId, die in der Ausgabe des vorherigen Befehls angezeigt werden. Diese Informationen werden für die GitHub-Workflow-Dateien benötigt.

## Open Tasks

- There is no cleanup for the generated QR codes. They should be deleted within a few minutes after creation.



```bash
git config --global --add safe.directory /workspaces/create-qr-codes-with-python
```