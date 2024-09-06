from dotenv import load_dotenv
load_dotenv()

from sys import argv
import os
import pathlib
from azure.core.credentials import AzureKeyCredential
import prompty
import prompty.azure
from prompty.tracer import trace, Tracer, PromptyTracer
import json
from typing import List
from azure.search.documents import SearchClient
from azure.search.documents.models import (
    VectorizedQuery
)
from openai import AzureOpenAI

@trace
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

@trace
def get_embedding(question: str):
    client = AzureOpenAI(       
                    api_key=os.environ["AZURE_OPENAI_KEY"],
                    api_version=os.environ["AZURE_OPENAI_API_VERSION"],
                    azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"]
                    )
                
    return client.embeddings.create(
            input=question,
            model="text-embedding-ada-002",
        ).data[0].embedding

@trace
def get_response(question):
    print("question:", question)
    embedding = get_embedding(question)
    print("embedding done")
    context = get_context(question, embedding)
    print("context:", context)
    print("getting result...")


    data_path = os.path.join(pathlib.Path(__file__).parent.resolve(), "./create_website_copy.prompty")
    prompty_obj = prompty.load(data_path)
    prepared_template = prompty.prepare(prompty_obj, inputs= {"question":question, "context":context})
    full_context = prepared_template[0]["content"]

    result = prompty.execute(data_path, inputs= {"question":question, "context":context})

    print("result:", result)

    return {"answer": result, "context": full_context}


if __name__ == "__main__":
    # add PromptyTracer
    local_trace = PromptyTracer()
    Tracer.add("PromptyTracer", local_trace.tracer)

    question = "Create the website copy for the tents catalog page"
    get_response(question)