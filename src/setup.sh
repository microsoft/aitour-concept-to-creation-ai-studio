#!/bin/bash

# Variables
resourceGroupName="aitour-concept-to-creation-ai-studio"
location="eastus2"  # Change to your preferred region
openAIInstanceName="aitour-concept-to-creation-ai-studio"
modelDeploymentName="gpt-35-turbo-16k"
modelName="gpt-35-turbo-16k"
modelCapacity="16k"
workspaceName="aitour-aml-workspace"
promptFlowFile="aitour-concept-to-creation-ai-studio\src\web_designer_flow\flow.dag.yaml" 

# Create the resource group
az group create --name $resourceGroupName --location $location

# Create the Azure OpenAI instance
az cognitiveservices account create \
    --name $openAIInstanceName \
    --resource-group $resourceGroupName \
    --kind OpenAI \
    --sku S0 \
    --location $location

# Deploy the model to the Azure OpenAI instance
az openai deployment create \
    --resource-group $resourceGroupName \
    --name $modelDeploymentName \
    --model $modelName \
    --capacity $modelCapacity \
    --instance $openAIInstanceName

# Output details of the deployment
az openai deployment show --resource-group $resourceGroupName --name $modelDeploymentName --instance $openAIInstanceName

# Create an Azure Machine Learning workspace
az ml workspace create --name $workspaceName --resource-group $resourceGroupName --location $location

# Enable Prompt Flow in the workspace (this command assumes Prompt Flow is enabled by default in supported regions)
az ml workspace update --name $workspaceName --resource-group $resourceGroupName --set features.prompt_flow=true

# Execute the Prompt Flow YAML
az ml job create --file $promptFlowFile --resource-group $resourceGroupName --workspace-name $workspaceName

# Output details of the workspace to confirm setup
az ml workspace show --name $workspaceName --resource-group $resourceGroupName
