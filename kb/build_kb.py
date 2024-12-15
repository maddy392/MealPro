import botocore
import boto3
import os
import time
import boto3
import logging
import pprint
import json
from knowledge_base import BedrockKnowledgeBase
import time


# Clients
session = boto3.session.Session(profile_name="mealPro", region_name="us-east-1")
s3_client = session.client('s3')
sts_client = session.client('sts')
region =  session.region_name
account_id = sts_client.get_caller_identity()["Account"]
bedrock_agent_client = session.client('bedrock-agent')
bedrock_agent_runtime_client = session.client('bedrock-agent-runtime') 
logging.basicConfig(format='[%(asctime)s] p%(process)s {%(filename)s:%(lineno)d} %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)


# Get the current timestamp
current_time = time.time()

# Format the timestamp as a string
timestamp_str = time.strftime("%Y%m%d%H%M%S", time.localtime(current_time))[-7:]
# Create the suffix using the timestamp
suffix = f"{timestamp_str}"
knowledge_base_name_standard = 'csv-metadata-kb'
knowledge_base_name_hierarchical = 'hierarchical-kb'
knowledge_base_description = "Knowledge Base csv metadata customization."
bucket_name = f'{knowledge_base_name_standard}-{suffix}'
foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"

knowledge_base_standard = BedrockKnowledgeBase(
    kb_name=f'{knowledge_base_name_standard}-{suffix}',
    kb_description=knowledge_base_description,
    data_bucket_name=bucket_name, 
    chunking_strategy = "FIXED_SIZE", 
    suffix = suffix
)


def upload_directory(path, bucket_name):
        for root,dirs,files in os.walk(path):
            for file in files:
                file_to_upload = os.path.join(root,file)
                print(f"uploading file {file_to_upload} to {bucket_name}")
                s3_client.upload_file(file_to_upload,bucket_name,file)

upload_directory("csv_data", bucket_name)

# ensure that the kb is available
time.sleep(30)
# sync knowledge base
knowledge_base_standard.start_ingestion_job()
kb_id_standard = knowledge_base_standard.get_knowledge_base_id()

query = "any salads please"
one_group_filter= {
    "greaterThan": {
        "key": "healthScore",
        "value": 60
    }
}
response = bedrock_agent_runtime_client.retrieve_and_generate(
    input={
        "text": query
    },
    retrieveAndGenerateConfiguration={
        "type": "KNOWLEDGE_BASE",
        "knowledgeBaseConfiguration": {
            'knowledgeBaseId': kb_id_standard,
            "modelArn": "arn:aws:bedrock:{}::foundation-model/{}".format(region, foundation_model),
            "retrievalConfiguration": {
                "vectorSearchConfiguration": {
                    "numberOfResults":5, 
                    "filter": one_group_filter
                } 
            }
        }
    }
)

pprint.pp(response['output']['text'])

response_standard = response['citations'][0]['retrievedReferences']
print("# of citations or chunks used to generate the response: ", len(response_standard))
def citations_rag_print(response_ret):
#structure 'retrievalResults': list of contents. Each list has content, location, score, metadata
    for num,chunk in enumerate(response_ret,1):
        print(f'Chunk {num}: ',chunk['content']['text'],end='\n'*2)
        print(f'Chunk {num} Location: ',chunk['location'],end='\n'*2)
        print(f'Chunk {num} Metadata: ',chunk['metadata'],end='\n'*2)

citations_rag_print(response_standard)

