from dotenv import load_dotenv
load_dotenv()

from sys import argv
import os
import pathlib
from azure.core.credentials import AzureKeyCredential
from promptflow.tools.common import init_azure_openai_client
from promptflow.connections import AzureOpenAIConnection
from promptflow.core import (AzureOpenAIModelConfiguration, Prompty, tool)
from typing import List
from azure.search.documents import SearchClient
from azure.search.documents.models import (
    VectorizedQuery
)

def retrieve_documentation(
    question: str,
    index_name: str,
    embedding: List[float],
) -> str:

    print("index name:", index_name)

    key = os.environ["AZURE_SEARCH_KEY"]
    search_client = SearchClient(
        endpoint=os.environ["AZURE_SEARCH_ENDPOINT"],
        index_name=index_name,
        credential=AzureKeyCredential(key)
    )

    vector_query = VectorizedQuery(
        vector=embedding, k_nearest_neighbors=3, fields="contentVector"
    )

    results = search_client.search(
        search_text=question,
        vector_queries=[vector_query],
        top=3
    )

    docs = [
        {
            "id": doc["id"],
            "title": doc["title"],
            "content": doc["content"],
            "url": doc["url"],
        }
        for doc in results
    ]

    return docs

def get_context(question, embedding):
    return retrieve_documentation(question=question, index_name=os.environ["AZURE_SEARCH_INDEX_NAME"], embedding=embedding)


def get_embedding(question: str):
    connection = AzureOpenAIConnection(        
                    azure_deployment="text-embedding-ada-002",
                    api_key=os.environ["AZURE_OPENAI_KEY"],
                    api_version=os.environ["AZURE_OPENAI_API_VERSION"],
                    api_base=os.environ["AZURE_OPENAI_ENDPOINT"]
                    )
                
    client = init_azure_openai_client(connection)

    return client.embeddings.create(
            input=question,
            model="text-embedding-ada-002",
        ).data[0].embedding
@tool
def get_response(question):
    print("question:", question)
    embedding = get_embedding(question)
    print("embedding done")
    context = get_context(question, embedding)
    print("context:", context)
    print("getting result...")

    configuration = AzureOpenAIModelConfiguration(
        azure_deployment="gpt-4o",
        api_key=os.environ["AZURE_OPENAI_KEY"],
        api_version=os.environ["AZURE_OPENAI_API_VERSION"],
        azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"]
    )
    override_model = {
        "configuration": configuration,
        "parameters": {"max_tokens": 512}
    }

    data_path = os.path.join(pathlib.Path(__file__).parent.resolve(), "./create_website_copy.prompty")
    prompty_obj = Prompty.load(data_path, model=override_model)

    result = prompty_obj(question = question, context = context)

    print("result: ", result)

    return {"answer": result, "context": context}
