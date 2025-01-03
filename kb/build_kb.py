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
timestamp_str = time.strftime("%Y%m%d%H%M", time.localtime(current_time))[2:]
# Create the suffix using the timestamp
suffix = f"{timestamp_str}"
knowledge_base_name_standard = 'csv-metadata-kb'
knowledge_base_name_hierarchical = 'hierarchical-kb'
knowledge_base_description = "Knowledge Base csv metadata customization."
bucket_name = f'{knowledge_base_name_standard}-{suffix}'
foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
data_path = "all_recipes"
print("========================================================================================")
print(suffix, knowledge_base_name_standard, bucket_name)

knowledge_base_standard = BedrockKnowledgeBase(
    kb_name=f'{knowledge_base_name_standard}-{suffix}',
    kb_description=knowledge_base_description,
    data_bucket_name=bucket_name, 
    chunking_strategy = "FIXED_SIZE", 
    suffix = suffix
)

print("========================================================================================")
# knowledge_base_standard.upload_directory(data_path)
# use aws s3 sync instead
# aws s3 sync all_recipes/ s3://<bucket-name>/ --profile mealPro  --dryrun

# sync knowledge base
knowledge_base_standard.start_ingestion_job()
kb_id_standard = knowledge_base_standard.get_knowledge_base_id()

query = "recipes"
one_group_filter = {'andAll': [{'listContains': {'key': 'dishTypes', 'value': 'salad'}}, {'listContains': {'key': 'cuisines', 'value': 'Southern'}}]}


response = bedrock_agent_runtime_client.retrieve(
    knowledgeBaseId="CBMFQH60JT", 
    retrievalQuery={
         "text": query
    }, 
    retrievalConfiguration={
        "vectorSearchConfiguration": {
            "numberOfResults": 5, 
            "filter": one_group_filter, 
            # "implicitFilterConfiguration": {
            #     "metadataAttributes": [
            #         {
            #             "description": "The ingredients that the recipe is made of. E.g. kale, cabbage etc.", 
            #             "key": "ingredients", 
            #             "type": "STRING_LIST"
            #         }
            #     ], 
            #     "modelArn": "anthropic.claude-3-5-sonnet-20240620-v1:0"
            # }
        }
    }
)

for num, retreivedDoc in enumerate(response["retrievalResults"], 1):
    print(f'Chunk {num}: ',retreivedDoc['content']['text'],end='\n'*2)
    print(f'Chunk {num} Ingredients: ',retreivedDoc['metadata']["ingredients"],end='\n'*2)
    print(f'Chunk {num} dishtypes: ',retreivedDoc['metadata']["dishTypes"],end='\n'*2)
    print(f'Chunk {num} Score: ',retreivedDoc['score'],end='\n'*2)


objects = s3_client.list_objects(Bucket=bucket_name)  
if 'Contents' in objects:
    for obj in objects['Contents']:
        s3_client.delete_object(Bucket=bucket_name, Key=obj['Key']) 
s3_client.delete_bucket(Bucket=bucket_name)

print("===============================Knowledge base==============================")
knowledge_base_standard.delete_kb(delete_s3_bucket=True, delete_iam_roles_and_policies=True)


# response = bedrock_agent_runtime_client.retrieve_and_generate(
#     input={
#         "text": query
#     },
#     retrieveAndGenerateConfiguration={
#         "type": "KNOWLEDGE_BASE",
#         "knowledgeBaseConfiguration": {
#             'knowledgeBaseId': kb_id_standard,
#             "modelArn": "arn:aws:bedrock:{}::foundation-model/{}".format(region, foundation_model),
#             "retrievalConfiguration": {
#                 "vectorSearchConfiguration": {
#                     "numberOfResults":5, 
#                     "filter": one_group_filter
#                 } 
#             }
#         }
#     }
# )

# pprint.pp(response['output']['text'])

# response_standard = response['citations'][0]['retrievedReferences']
# print("# of citations or chunks used to generate the response: ", len(response_standard))
# def citations_rag_print(response_ret):
# #structure 'retrievalResults': list of contents. Each list has content, location, score, metadata
#     for num,chunk in enumerate(response_ret,1):
#         print(f'Chunk {num}: ',chunk['content']['text'],end='\n'*2)
#         print(f'Chunk {num} Location: ',chunk['location'],end='\n'*2)
#         print(f'Chunk {num} Metadata: ',chunk['metadata'],end='\n'*2)

# citations_rag_print(response_standard)