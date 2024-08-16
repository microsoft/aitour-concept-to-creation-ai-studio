
# Azure CLI Automation Script for AI and Machine Learning Resources

This script automates the creation of a resource group, an Azure OpenAI instance, the deployment of the `gpt-35-turbo-16k` model, and an Azure Machine Learning workspace with Prompt Flow enabled, and opens an existing Prompt Flow YAML file.

## Prerequisites

- Azure CLI installed on your machine.
- Extensions for Azure OpenAI and Azure Machine Learning installed.

To install the required CLI extensions, run:
```bash
az extension add --name openai
az extension add --name ml
```

## Usage

### 1. Customize the location:

Replace the `location`: with your preferred Azure region (Default: eastus2).

### 2. Run the Script

1. Make the script executable:
   ```bash
   chmod +x setup.sh
   ```
2. Run the script:
   ```bash
   ./setup.sh
   ```
