import boto3
from botocore.exceptions import ClientError
import time
import json
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


session = boto3.Session(profile_name="mealPro")
bedrock_agent_client = session.client(
	service_name="bedrock-agent", 
	region_name="us-east-1"
	)

def create_or_update_agent(agent_name, foundation_model, role_arn, instruction, postProcessingPrompt=None):
	"""
	Creates an agent that orchestrates interactions between foundation models,
	data sources, software applications, user conversations, and APIs to carry
	out tasks to help customers.

	:param agent_name: A name for the agent.
	:param foundation_model: The foundation model to be used for orchestration by the agent.
	:param role_arn: The ARN of the IAM role with permissions needed by the agent.
	:param instruction: Instructions that tell the agent what it should do and how it should
						interact with users.
	:return: The response from Agents for Bedrock if successful, otherwise raises an exception.
	"""
	try:

		existing_agents = bedrock_agent_client.list_agents()["agentSummaries"]
		existing_agent = next((agent for agent in existing_agents if agent["agentName"] == agent_name), None)

		if existing_agent:
			if postProcessingPrompt:
				response = bedrock_agent_client.update_agent(
					agentId=existing_agent["agentId"],
					agentName=agent_name,
					foundationModel=foundation_model,
					agentResourceRoleArn=role_arn,
					instruction=instruction,
					promptOverrideConfiguration = {
						"promptConfigurations": [
							{
								"basePromptTemplate": postProcessingPrompt, 
								"promptState": "ENABLED",
								"promptCreationMode": "OVERRIDDEN",
								"promptType": "POST_PROCESSING", 
								"inferenceConfiguration": {
									"maximumLength": 1000, 
									"stopSequences": [
										"\t\tHuman:"
									], 
									"temperature": 0,
									"topP": 1, 
									"topK": 250
								}
							}
						]
					}
				)
			else:
				response = bedrock_agent_client.update_agent(
					agentId=existing_agent["agentId"],
					agentName=agent_name,
					foundationModel=foundation_model,
					agentResourceRoleArn=role_arn,
					instruction=instruction
				)
			print(f"Agent '{agent_name}' updated successfully.")

		else:
			response = bedrock_agent_client.create_agent(
				agentName=agent_name,
				foundationModel=foundation_model,
				agentResourceRoleArn=role_arn,
				instruction=instruction,
			)
			print(f"Agent '{agent_name}' created successfully.")

	except ClientError as e:
		logger.error(f"Error: Couldn't create agent. Here's why: {e}")
		raise
	else:
		return response["agent"]


def prepare_agent(agent_id):
	response = bedrock_agent_client.prepare_agent(agentId=agent_id)
	try:
		print(f"Agent preparation initiated. Status: {response['agentStatus']}")
		return response['agentStatus']
	except ClientError as e:
		print(f"Error preparing agent: {e}")
		raise


def wait_for_agent_preparation(agent_id, max_attempts=30, delay=10):
    for _ in range(max_attempts):
        try:
            response = bedrock_agent_client.get_agent(agentId=agent_id)
            status = response['agent']['agentStatus']
            if status == 'PREPARED':
                print("Agent preparation completed.")
                return True
            elif status == 'FAILED':
                print(f"Agent preparation failed or stopped. Status: {status}")
                return False
            else:
                print(f"Agent preparation in progress. Current status: {status}")
                time.sleep(delay)
        except ClientError as e:
            print(f"Error checking agent status: {e}")
            raise
    print("Timed out waiting for agent preparation.")
    return False


agent_name = "MealPro"
foundation_model = "anthropic.claude-3-haiku-20240307-v1:0"
agentResourceRoleArn = "arn:aws:iam::294090989896:role/service-role/AmazonBedrockExecutionRoleForAgents_5SVAH2QGYCW"
instruction = """You are a helpful AI agent that helps the user to plan a meal plan using recipes that are provided for you via action group functions. Reply with recipes that are provided to you via response of action groups only. if the action group response fails recipes politely decline to answer the user. The Action groups will respond with a json response. Please respond to the user requests in a json output format only."""
 
agent = create_or_update_agent(
	agent_name = agent_name,
	foundation_model=foundation_model,
	role_arn=agentResourceRoleArn,
	instruction=instruction, 
	# postProcessingPrompt=postProcessingPrompt
)


agent_id = agent['agentId']
print(f"Agent ID: {agent_id}")

# Prepare the agent
prepare_status = prepare_agent(agent_id)

# Wait for preparation to complete
if wait_for_agent_preparation(agent_id):
	print(f"Agent prepared: {agent_id}")
	# print(bedrock_agent_client.get_agent(agentId=agent_id)['agent'])
    # # Create agent version
    # agent_version = create_agent_version(agent_id)
    # print(f"Agent version created: {agent_version}")
else:
    print("Failed to prepare agent. Cannot create version.")