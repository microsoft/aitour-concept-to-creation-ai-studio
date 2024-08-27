# Demo 3 - Add your own data with Prompt Flow

In the previous demo you discovered the Playground and interacted with the model through the chat interface. In this demo, you will learn how to build your first gen AI application in [Prompt Flow](https://learn.microsoft.com/azure/ai-studio/how-to/prompt-flow?WT.mc_id=academic-140829-cacaste) and connect it to your business data, to provide accurate responses grounded on your data sources.

## Add your data to Azure AI Studio Hub

In the [setup](./media/set_up.md) section, you created an Azure AI Search service and connected it to your Azure AI Studio hub. Now you will populate your Azure AI Search service with your business data.

Let's start by adding a new data source to your Azure AI Studio Hub.

1. Download the [Contoso products Catalog](./data/products.csv) csv file, a sample dataset that contains product information.
1. Go to the Azure AI Studio Hub and click on the **Data** tab.
1. Click on the **+ New data** button to create a new data source.
1. In the Add your data wizard, expand the drop-down menu to select **Upload files/folders**.
1. Select the **Upload file** and then the *product.csv* file from your local path. 
1. Name the data source and wait for the file to be uploaded.

Next, you will create a new index in your Azure AI Search service to store the product data and make it searchable.

1. Go to **Search** tab in the Azure AI Studio Hub.
1. Click on the **+ New index** button.
1. Select **Data in Azure AI Studio** as the data source and then the data source you just uploaded.
1. In the **Index Settings** section, select the *AzureAISearch* connection you created in the setup phase
1. In the **Search Setting** section, make sure that vectorization is enabled and select the default Azure OpenAI resource for your hub as *embedding* model.

Wait for the indexing process to be completed, which can take several minutes. The index creation operation consists of the following jobs:

- Crack, chunk, and embed the text tokens in your products data.
- Create the Azure AI Search index.
- Register the index asset.

## Build your first Gen AI solution

Now that your index has been registered in your Azure AI Studio project and is ready to be used, you can build and test your first LLMs-based solution to interact with your data.

All the app source code is stored in the *web_designer_flow* folder. It includes:
- A **flow.flex.yaml** file that defines the structure of the flow. 



This is a simple example of a DAG flow that connects to your business data, but you can build more complex flows by adding more nodes and connections. For example, you can add a [Python tool](https://learn.microsoft.com/azure/ai-studio/how-to/prompt-flow-tools/python-tool?WT.mc_id=academic-140829-cacaste) to your flow to perform custom operations on your data, format your output as needed or integrate with 3rd party services. 