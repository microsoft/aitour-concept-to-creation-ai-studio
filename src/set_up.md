
# Demo Setup - Azure Portal and Azure CLI


## Demo Prerequistes: 

- You will need an Azure account.  If you don't have an Azure account, you can create one for free [here](https://azure.microsoft.com/en-us/free/).

- Make sure that you have capacity for the OpenAI resources you are creating in your Azure subscription.  Note that not all OpenAI resources are available in all regions, so make sure to check availability and choose a region that supports this demo, specifically the gpt-4o, gpt-4 and text-embedding-ada-002 models.
For more information, see [https://docs.microsoft.com/en-us/azure/openai/overview](https://docs.microsoft.com/en-us/azure/openai/overview).

- You will need an IDE to build and test your first LLMs-based application. You can choose to work on your local [Visual Studio Code](https://code.visualstudio.com/) desktop app or run a [GitHub Codespace](https://github.com/features/codespaces) in the browser. You can click on the button below to open this repo in a GitHub Codespace.

 [![Open in GitHub Codespaces](https://img.shields.io/static/v1?style=for-the-badge&label=GitHub+Codespaces&message=Open&color=brightgreen&logo=github)](https://github.com/codespaces/new?hide_repo_select=true&machine=basicLinux32gb&repo=826281335&ref=main&devcontainer_path=.devcontainer%2Fdevcontainer.json&geo=UsEast)

> [!NOTE] 
> OpenAI resources are amazing but can be EXPENSIVE!  Make sure you review the costs associated with the OpenAI resources that you are creating.

## Option 1: Set up the demos using the Azure Portal and the Azure AI Studio UI

Follow the steps below to set up the Azure AI Studio environment for this demo.

1. Navigate to [Azure AI Studio](ai.azure.com) and login with your Azure account. A hub provides a collaborative workspace to host your projects.
1. In the *Management* section, go to *All hubs* and then *Create a new hub*
1. In the configuration page, fill in the required fields. The recommended location for running this demo is **Sweden Central**, for the sake of models availability. Create a new Azure AI services to enable access to Azure OpenAI Service and an AI Search service to enable the search functionality.
![Hub configuration](./media/hub_configuration.png)
1. Once the hub is created, navigate to *All projects* and click on *+ New Project* to create a new project. Make sure you select the hub you just created. 
1. In your newly created project, navigate to the *Deployments* page, under the *Components* section. Click on *+ Create deployment* to create a new deployment. For this demo you'll need 3 gpt instances: *gpt-4o*, *gpt-4* and *text-embedding-ada-002*. This is how your project's deployments section should look like:
![Deployments section](./media/deployments.png)
At the end of this step, if you navigate to the [Azure Portal](portal.azure.com) your project resource group should look like this:
![Azure resource group](./media/azure_rg.png)
where the key vault and the storage account are created by default when you create a new Azure AI Studio hub.

## Option 2: Azure CLI Automation Script

*Warning:* An .env file with hard-coded values for local demos and testing will be created in the src directory
This file is used to store the environment variables for the project for demos and testing only
Please do not share this file, or commit this file to the repository
Delete this file when done with demos, or if you are not using it


### Azure CLI Prerequisites

- The Azure CLI must be installed, or you can use GitHub Codespaces or the Azure Cloud Shell.  Get the Azure CLI at [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). If you are not using the Azure Cloud Shell, you should login from the terminal to the Azure subscription where you want to provision the Azure AI resources. Use the following command to sign in:
```bash
az login --use-device-code
```
- You can use the included CLI in GitHub Codespaces to run the script in a browser-based environment.  For more information, see [https://docs.github.com/codespaces](https://docs.github.com/en/codespaces). 
- You can also use the included CLI in the Azure Cloud Shell to run the script in a browser-based environment.  For more information, see [https://docs.microsoft.com/azure/cloud-shell/overview](https://docs.microsoft.com/en-us/azure/cloud-shell/overview).
- The extension for Azure Machine Learning must be installed.  See [https://docs.microsoft.com/azure/machine-learning/how-to-configure-cli](https://docs.microsoft.com/en-us/azure/machine-learning/how-to-configure-cli) for configuration instructions.

To install the Azure Machine Learning extension, run:
```bash
az extension add --name ml
```
>[!NOTE]
>If you are using GitHub Codespaces, the Azure Machine Learning extension is already installed.


### Usage

### 1. Customize the location:

Replace the `location`: with your preferred Azure region (Default: swedencentral).

### 2. Run the Script

1. Make the script executable:
   ```bash
   chmod +x set_up.sh
   ```
2. Run the script:
   ```bash
   ./set_up.sh
   ```