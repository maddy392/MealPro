import botocore
import boto3
import os
import time
import boto3
import logging
import pprint
import json
import time


# Clients
session = boto3.session.Session(profile_name="mealPro", region_name="us-east-1")
region =  session.region_name
bedrock_agent_client = session.client('bedrock-agent')
bedrock_agent_runtime_client = session.client('bedrock-agent-runtime') 
logging.basicConfig(format='[%(asctime)s] p%(process)s {%(filename)s:%(lineno)d} %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)
knowledge_base_id = "WGVGYSRSZJ"


query = "any dumplings?"
one_group_filter = {'listContains': {'key': 'dishTypes', 'value': 'appetizer'}}


response = bedrock_agent_runtime_client.retrieve(
    knowledgeBaseId=knowledge_base_id, 
    retrievalQuery={
         "text": query
    }, 
    retrievalConfiguration={
        "vectorSearchConfiguration": {
            "numberOfResults": 5, 
            "overrideSearchType": "HYBRID", 
            "filter": one_group_filter
        }
    }
)

for num, retreivedDoc in enumerate(response["retrievalResults"], 1):
    print(f'Chunk {num}: ',retreivedDoc['content']['text'],end='\n'*2)
    print(f'Chunk {num} title: ',retreivedDoc['metadata']["title"],end='\n'*2)
    print(f'Chunk {num} Ingredients: ',", ".join(sorted(retreivedDoc['metadata']["ingredients"])),end='\n'*2)
    print(f'Chunk {num} Score: ',retreivedDoc['score'],end='\n'*2)