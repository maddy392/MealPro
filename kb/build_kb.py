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
timestamp_str = time.strftime("%Y%m%d%H%M", time.localtime(current_time))[4:]
# Create the suffix using the timestamp
suffix = f"{timestamp_str}"
knowledge_base_name_custom = 'custom-chunking-kb'
knowledge_base_description = "Knowledge Base csv metadata customization with custom chunking for title and ingredients"
lambda_function_name = f'{knowledge_base_name_custom}-lambda-{suffix}'
bucket_name = f'{knowledge_base_name_custom}-{suffix}'
intermediate_bucket_name = f'{knowledge_base_name_custom}-intermediate-{suffix}'
foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
data_path = "all_recipes"
print("========================================================================================")
print(suffix, knowledge_base_name_custom, bucket_name)

knowledge_base_custom = BedrockKnowledgeBase(
    kb_name=f'{knowledge_base_name_custom}-{suffix}',
    kb_description=knowledge_base_description,
    data_bucket_name=bucket_name, 
    lambda_function_name=lambda_function_name, 
    intermediate_bucket_name=intermediate_bucket_name,
    chunking_strategy = "CUSTOM", 
    suffix = f'{suffix}-c'
)

# knowledge_base_standard.create_lambda()

print("========================================================================================")
# knowledge_base_standard.upload_directory(data_path)
# use aws s3 sync instead
# aws s3 sync all_recipes_with_ingredients/ s3://custom-chunking-kb-01100015/ --profile mealPro  --dryrun

# sync knowledge base
knowledge_base_custom.start_ingestion_job()
kb_id_custom = knowledge_base_custom.get_knowledge_base_id()

query = "basmati rice (1.0 servings), cinnamon (0.25 sticks), cumin (0.13 teaspoon), ginger juice (0.13 teaspoon), ground chili (0.13 tablespoon), ground coriander (0.25 teaspoons), ground turmeric (0.38 teaspoons), oil (1.0 servings), onions (0.13 cup), pods cardamom (0.38 ), potatoes (0.06 pound), prawns (0.25 lbs), salt (1.0 servings), sugar (0.13 teaspoon), tomatoes (0.25 ), yogurt (0.5 ounces)"
one_group_filter = {'andAll': [{'lessThan': {'key': 'healthScore', 'value': 30}}, {'equals': {'key': 'chunk_type', 'value': "ingredients"}}]}


response = bedrock_agent_runtime_client.retrieve(
    knowledgeBaseId=kb_id_custom, 
    retrievalQuery={
         "text": query
    }, 
    retrievalConfiguration={
        "vectorSearchConfiguration": {
            "numberOfResults": 5, 
            "overrideSearchType": "HYBRID"
            # "filter": one_group_filter, 
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
    print(f'Chunk {num} title: ',retreivedDoc['metadata']["title"],end='\n'*2)
    print(f'Chunk {num} Ingredients: ',", ".join(sorted(retreivedDoc['metadata']["ingredients"])),end='\n'*2)
    print(f'Chunk {num} Score: ',retreivedDoc['score'],end='\n'*2)


objects = s3_client.list_objects(Bucket=bucket_name)  
if 'Contents' in objects:
    for obj in objects['Contents']:
        s3_client.delete_object(Bucket=bucket_name, Key=obj['Key']) 
s3_client.delete_bucket(Bucket=bucket_name)

print("===============================Knowledge base==============================")
knowledge_base_custom.delete_kb(delete_s3_bucket=True, delete_iam_roles_and_policies=True)


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