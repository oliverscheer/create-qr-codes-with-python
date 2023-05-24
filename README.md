# QR Code Generator App in Python & Flask

This repository contains a Web App that can be used to generate QR codes for WiFi access, Contact details, or URLs.

This web app is for demo and training purposes only.

It contains:

- The infrastructure is set up leveraging an Azure CLI script
- The continuous deployment is done with GitHub Actions
- The web app is written in Python using Flask as web server

## Setting up the infrastructure and deploy the app

1. To leverage GitHub Actions, you should first fork this repository. Because then you can use GitHub Actions later to deploy to your own Azure Subscription continuously.

1. Login in to Azure and check that the default subscription is set correctly for you.

    ```bash
    az login
    az account show
    ```

1. Set the environment variables that are required for the installation

    ```bash
    export WEB_APP_NAME=<app name>
    export RESOURCE_GROUP_NAME=<resource group name>
    export LOCATION=<azure region>
    export SKU=<sku for example F1 or B1>
    ```

1. Run `setup_infrastructure.sh`

   ```bash
   chmod +x setup_infrastructure.sh
   .\setup_infrastructure.sh
   ```

    Keep the Information for the Service Principal. These information are required to create the Azure Access Secret in GitHub later.

    Also keep the link to your new created web app, which is empty right now.

1. Create Azure Credentials for GitHub

    Take the information from the last step and create a json snippet like the following and insert the values.

    ```json
    {
        "clientId": "YOUR_APP_ID",
        "clientSecret": "YOUR_PASSWORD",
        "subscriptionId": "YOUR_SUBSCRIPTION_ID",
        "tenantId": "YOUR_TENANT_ID"
    }
    ```

1. Create a Secret for your repository

    On GitHub in your repository, go to:

    Settings --> Secrets and variables --> Actions

    Create a 'New Repository Secret' with the name 'AZURE_CREDENTIALS' and paste the Json snippet from the last step.

1. Trigger the GitHub Action 'Deploy QR Code App'

    You can do it manually or with a push of some changes to the main branch.

After this you should be able to open the web app under the link you got a few steps earlier.

## Open Tasks

- There is no cleanup for the generated QR codes. They should be deleted within a few minutes after creation.

## Remarks

- Why am I not using the deployment from GitHub on Azure directly?

    This is a very easy to setup step, but requires manually interaction on the portal, or additional scripts.

- Coming soon, a deployment via bicep

- Main branch is protected and requires puöl requests

## Summary

I hope you enjoyed the demo. If you have questions feel free to comment.
