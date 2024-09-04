#!/bin/bash  

prefix="BRK441"
location="swedencentral"
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
az cognitiveservices account deployment create --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --deployment-name "gpt-4o" --model-name "gpt-4o" --model-version "2024-05-13" --model-format "OpenAI" --sku-capacity "1" --sku-name "Standard" --capacity "20"

# Deploying GPT-4 in Azure AI Service
echo "Deploying GPT-4"
az cognitiveservices account deployment create --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --deployment-name "gpt-4" --model-name "gpt-4" --model-format "OpenAI" --model-version "0613" --sku-capacity "1" --sku-name "Standard" --capacity "20"

# Deploying GPT-4 in Azure AI Service
echo "Deploying Text-embedding-ada-002"
az cognitiveservices account deployment create --name $ai_resource_ai_service --resource-group $ai_resource_name_resource_group_name --deployment-name "text-embedding-ada-002" --model-name "text-embedding-ada-002" --model-format "OpenAI" --model-version "2" --sku-capacity "1" --sku-name "Standard" --capacity "20"

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

# Security
#echo "Disable storage SAS keys"
#storage_resource_id=$(az ml workspace show --name $ai_resource_name_hub_name --resource-group $ai_resource_name_resource_group_name --query storage_account --output tsv)
#storage_name=$(echo $storage_resource_id | awk -F'/' '{print $NF}') 
#az storage account update --name $storage_name --resource-group $ai_resource_name_resource_group_name --allow-shared-key-access false   > null
#az storage account update --name $storage_name --resource-group $ai_resource_name_resource_group_name --min-tls-version TLS1_2  

az role assignment create --role "Storage Blob Data Contributor" --scope /subscriptions/$subscription_id/resourceGroups/$ai_resource_name_resource_group_name --assignee-principal-type User --assignee-object-id $user_id

# Search service creation
tmp_name=$ai_resource_name"-aisearch"
ai_resource_ai_search="${tmp_name,,}"
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

# Search index creation
index_name="products-catalog"
index_schema='{
  "name": "'$index_name'",
  "fields": [
    {"name": "id", "type": "Edm.String", "key": true, "searchable": false},
    {"name": "name", "type": "Edm.String", "searchable": true},
    {"name": "price", "type": "Edm.Double", "filterable": true, "sortable": true},
    {"name": "category", "type": "Edm.String", "searchable": true},
    {"name": "brand", "type": "Edm.String", "searchable": true},
    {"name": "description", "type": "Edm.String", "searchable": true}
  ]
}'

echo "Creating search index: $index_name"

curl -X POST "$search_url/indexes?api-version=2020-06-30" \
     -H "Content-Type: application/json" \
     -H "api-key: $search_key" \
     -d "$index_schema"

$json_file="data/products.json"

# Upload JSON data to the search index from the products.json file
data=$(jq -c '.[] | { "@search.action": "upload", id: .id, name: .name, price: .price, category: .category, brand: .brand, description: .description }' $json_file | jq -s '{ "value": . }')

curl -X POST "$search_url/indexes/$index_name/docs/index?api-version=2020-06-30" \
     -H "Content-Type: application/json" \
     -H "api-key: $search_key" \
     -d "$data"
