import boto3
from botocore.exceptions import ClientError
import json
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

session = boto3.Session(profile_name="mealPro")
bedrock_agent_runtime_client = session.client(
    service_name="bedrock-agent-runtime",
    region_name="us-east-1"
)
# Invoke the agent
response = bedrock_agent_runtime_client.invoke_agent(
    agentId='TKAFFO7AR2',
    agentAliasId='TSTALIASID',
    sessionId='TestSession',
    inputText='I like Mediterranean or Italian recipes', 
	enableTrace=True
)

# Access the event stream in the response
event_stream = response['completion']

# Process each event in the event stream
for event in event_stream:
    print("Received event:", event)

    # Check if the event contains a chunk of data
    if 'chunk' in event:
        chunk_data = event['chunk']
        print("Chunk data:", chunk_data)

    # Handle other specific events as needed (e.g., accessDeniedException)
    if 'accessDeniedException' in event:
        print("Access Denied:", event['accessDeniedException'])



# Invoke the agent
# response = bedrock_agent_runtime_client.invoke_agent(
#     agentId='TKAFFO7AR2',
#     agentAliasId='TSTALIASID',
#     sessionId='TestSession',
#     inputText='recipes similar to recipeId: 644390', 
# 	enableTrace=True
# )

# # Access the event stream in the response
# event_stream = response['completion']

# # Process each event in the event stream
# for event in event_stream:
#     print("Received event:", event)

#     # Check if the event contains a chunk of data
#     if 'chunk' in event:
#         chunk_data = event['chunk']
#         print("Chunk data:", chunk_data)

#     # Handle other specific events as needed (e.g., accessDeniedException)
#     if 'accessDeniedException' in event:
#         print("Access Denied:", event['accessDeniedException'])