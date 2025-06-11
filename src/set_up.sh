#!/bin/bash  

prefix="BRK441"
location="eastus2" # Change this to your preferred location
subscription_id=$(az account show --query id --output tsv)
user_id=$(az ad signed-in-user show --query id --output tsv)

ai_resource_name="$prefix-$(shuf -i 1000-9999 -n 1)"
echo "Resource name: $ai_resource_name"  

# Create the resource group
ai_resource_name_resource_group_name=$ai_resource_name"_RG"
echo "Creating resource group: $ai_resource_name_resource_group_name"
az group create --name $ai_resource_name_resource_group_name --location $location > null

# Create the Hub
ai_resource_name_hub_name=$ai_resource_name"-hub"
echo "Creating AI Studio Hub: $ai_resource_name_hub_name"
az ml workspace create --kind hub --resource-group $ai_resource_name_resource_group_name --name $ai_resource_name_hub_name > null

# Create project in Hub
hub_id=$(az ml workspace show  -g $ai_resource_name_resource_group_name --name $ai_resource_name_hub_name --query id --output tsv)
ai_resource_project_name=$ai_resource_name"-project"
echo "Creating AI Studio Project: $ai_resource_project_name"
az ml workspace create --kind project --resource-group $ai_resource_name_resource_group_name --name $ai_resource_project_name --hub-id $hub_id > null

# Create a Azure AI Service Account
ai_resource_ai_service=$ai_resource_name"-aiservice"
echo "Creating AI Service Account: $ai_resource_ai_service"
az cognitiveservices account create --kind AIServices --location $location --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --sku S0 --yes > null

# Deploying GPT-4o in Azure AI Service
echo "Deploying GPT-4o"
az cognitiveservices account deployment create --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --deployment-name "gpt-4o" --model-name "gpt-4o" --model-version "2024-11-20" --model-format "OpenAI" --sku-capacity "1" --sku-name "GlobalStandard" --capacity "120"

# Deploying GPT-4 in Azure AI Service
echo "Deploying GPT-4"
az cognitiveservices account deployment create --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --deployment-name "gpt-4" --model-name "gpt-4" --model-format "OpenAI" --model-version "turbo-2024-04-09" --sku-capacity "1" --sku-name "GlobalStandard" --capacity "20"

# Deploying Text Embedding ADA 002 in Azure AI Service
echo "Deploying text-embedding-ada-002"
az cognitiveservices account deployment create --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --deployment-name "text-embedding-ada-002" --model-name "text-embedding-ada-002" --model-format "OpenAI" --model-version "2" --sku-capacity "1" --sku-name "Standard" --capacity "120"

# Adding connection to the AI Hub
echo "Adding AI Service Connection to the HUB"
ai_service_resource_id=$(az cognitiveservices account show --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --query id --output tsv)
ai_service_api_key=$(az cognitiveservices account keys list --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --query key1 --output tsv)

rm connection.yml   
echo "name: $ai_resource_ai_service" >> connection.yml  
echo "type: azure_ai_services" >> connection.yml  
echo "endpoint: https://$location.api.cognitive.microsoft.com/" >> connection.yml  
echo "api_key: $ai_service_api_key" >> connection.yml  
echo "ai_services_resource_id:  $ai_service_resource_id" >> connection.yml  

az ml connection create --file connection.yml --resource-group $ai_resource_name_resource_group_name --workspace-name  $ai_resource_name_hub_name > null
rm connection.yml 

az role assignment create --role "Storage Blob Data Contributor" --scope /subscriptions/$subscription_id/resourceGroups/$ai_resource_name_resource_group_name --assignee-principal-type User --assignee-object-id $user_id

# Search service creation
tmp_name=$ai_resource_name"-aisearch"
# This forces to lower case, which is required to create the search service. If this fails (e.g. on MacOS), you can use something like the commented line immediately below instead
ai_resource_ai_search="${tmp_name,,}"
# export ai_resource_ai_search="brk441-az-aisearch"
az search service create --name $ai_resource_ai_search --resource-group $ai_resource_name_resource_group_name --sku basic --partition-count 1 --replica-count 1

search_url="https://"$ai_resource_ai_search".search.windows.net"
search_key=$(az search admin-key show --service-name $ai_resource_ai_search --resource-group $ai_resource_name_resource_group_name --query primaryKey --output tsv)

echo "name: $ai_resource_ai_search" >> connection_search.yml  
echo "type: azure_ai_search" >> connection_search.yml  
echo "endpoint: $search_url" >> connection_search.yml  
echo "api_key: $search_key" >> connection_search.yml  

az ml connection create --file connection_search.yml --resource-group $ai_resource_name_resource_group_name --workspace-name  $ai_resource_name_hub_name > null
rm connection_search.yml  

# create an .env file with hard-coded values for local demos and testing.  

echo "An .env file with hard-coded values for local demos and testing has been created in the src directory"
echo "Please do not share this file, or commit this file to the repository"
echo "This file is used to store the environment variables for the project for demos and testing only"
echo "Delete this file when done with demos, or if you are not using it"

echo "# Please do not share this file, or commit this file to the repository" > .env
echo "# This file is used to store the environment variables for the project for demos and testing only" >> .env
echo "# delete this file when done with demos, or if you are not using it" >> .env
echo "AZURE_OPENAI_ENDPOINT=https://$location.api.cognitive.microsoft.com/" >> .env
echo "AZURE_OPENAI_KEY=$ai_service_api_key" >> .env
echo 'AZURE_OPENAI_API_VERSION="2023-03-15-preview"' >> .env
echo 'AZURE_SEARCH_INDEX_NAME="products-catalog"' >> .env
echo "AZURE_SEARCH_ENDPOINT=$search_url" >> .env
echo "AZURE_SEARCH_KEY=$search_key" >> .env
echo "AZURE_SUBSCRIPTION_ID=$subscription_id" >> .env
echo "AZURE_RESOURCE_GROUP=$ai_resource_name_resource_group_name" >> .env
echo "AZURE_AI_PROJECT_NAME=$ai_resource_project_name" >> .env
