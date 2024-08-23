#!/bin/bash

# Variables
resourceGroupName="aitourbrk441k"
openAIInstanceName="aitourbrk441k-openai"
location="swedencentral"  # Change to your preferred region
workspaceName="aitour-aml-workspace"
promptFlowFile="flow.dag.yaml" 

src\web_designer_flow\flow.dag.yaml


# Create the resource group
echo "Creating resource group $resourceGroupName in location $location"
az group create --name $resourceGroupName --location $location

# Create the Azure OpenAI instance
echo "Creating Azure OpenAI instance $openAIInstanceName in $resourceGroupName in location $location"
az cognitiveservices account create \
    --kind OpenAI \
    --location $location \
    --name $openAIInstanceName \
    --resource-group $resourceGroupName \
    --sku S0

# Check for available SKUs at this location
echo "Available SKUs at $location:"
az cognitiveservices account list-skus --kind OpenAI --location $location --output table

# Deploy the 3 gpt instances to the model Azure OpenAI instance: gpt-4o, gpt-4 and text-embedding-ada-002

echo "Available models in $openAIInstanceName:"
az cognitiveservices account list-models --name $openAIInstanceName --resource-group $resourceGroupName --output table

# Deploy gpt-4o
echo "Deploying gpt-4o to $openAIInstanceName in $resourceGroupName in location $location"

az cognitiveservices account deployment create \
    --model-format OpenAI \
    --model-name gpt-4o \
    --model-version 2024-05-13 \
    --name $openAIInstanceName \
    --resource-group $resourceGroupName

# Deploy gpt-4
echo "Deploying gpt-4 to $openAIInstanceName in $resourceGroupName in location $location"

az cognitiveservices account deployment create \
    --model-format OpenAI \
    --model-name gpt-4 \
    --model-version 0613 \
    --name $openAIInstanceName \
    --resource-group $resourceGroupName

# Deploy text-embedding-ada-002
echo "Deploying text-embedding-ada-002 to $openAIInstanceName in $resourceGroupName in location $location"

az cognitiveservices account deployment create \
    --model-format OpenAI \
    --model-name text-embedding-ada-002 \
    --model-version 2 \
    --name $openAIInstanceName \
    --resource-group $resourceGroupName

# Output details of the deployment
az cognitiveservices account deployment show --resource-group $resourceGroupName --name $modelDeploymentName --instance $openAIInstanceName

# Create an Azure Machine Learning workspace
echo "Creating Azure Machine Learning workspace $workspaceName in $resourceGroupName in location $location"
az ml workspace create --name $workspaceName --resource-group $resourceGroupName --location $location


# Execute the Prompt Flow YAML
cd web_designer_flow
echo "Executing the Prompt Flow YAML $promptFlowFile in $workspaceName in $resourceGroupName"
az ml job create --file $promptFlowFile --resource-group $resourceGroupName --workspace-name $workspaceName
cd ..

# Output details of the workspace to confirm setup
echo "Details of the workspace $workspaceName:"
az ml workspace show --name $workspaceName --resource-group $resourceGroupName
