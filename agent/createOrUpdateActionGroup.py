import boto3
from botocore.exceptions import ClientError
# import yaml
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
bedrock_agent_runtime_client = session.client(
    service_name="bedrock-agent-runtime",
    region_name="us-east-1"
)



def create_or_update_agent_action_group(
	name, description, agent_id, agent_version, function_arn, function_schema
):
	"""
	Creates an action group for an agent. An action group defines a set of actions that an
	agent should carry out for the customer.

	:param name: The name to give the action group.
	:param description: The description of the action group.
	:param agent_id: The unique identifier of the agent for which to create the action group.
	:param agent_version: The version of the agent for which to create the action group.
	:param function_arn: The ARN of the Lambda function containing the business logic that is
							carried out upon invoking the action.
	:param api_schema: Contains the OpenAPI schema for the action group.
	:return: Details about the action group that was created.
	"""

	# list agent's action groups
	existing_action_groups = bedrock_agent_client.list_agent_action_groups(
			agentId=agent_id,
			agentVersion=agent_version
		)["actionGroupSummaries"]
	existing_action_group = next((group for group in existing_action_groups if group["actionGroupName"] == name), None)
	try: 
		if existing_action_group:
			existing_action_groupID = existing_action_group["actionGroupId"]
			response = bedrock_agent_client.update_agent_action_group(
				actionGroupName=name,
				actionGroupId=existing_action_groupID,
				description=description,
				agentId=agent_id,
				agentVersion=agent_version,
				actionGroupExecutor={"lambda": function_arn},
				functionSchema=function_schema
			)
			agent_action_group = response["agentActionGroup"]
			print(f"Agent action group {name} updated.")
		else:
			response = bedrock_agent_client.create_agent_action_group(
				actionGroupName=name,
				description=description,
				agentId=agent_id,
				agentVersion=agent_version,
				actionGroupExecutor={"lambda": function_arn},
				functionSchema=function_schema
				# apiSchema={"payload": json.dumps(api_schema)},
			)
			print(f"Agent action group {name} created.")
			agent_action_group = response["agentActionGroup"]
	except ClientError as e:
		logger.error(f"Error: Couldn't create agent action group. Here's why: {e}")
		logger.error(f"Error Code: {e.response['Error']['Code']}")
		logger.error(f"Error Message: {e.response['Error']['Message']}")
		raise
	else:
		return agent_action_group

response = create_or_update_agent_action_group(
	name="getRecipesActionGroup",
	description="This Action Group fetches recipes based on user preferences. Convert user query into a crisp query and pass on as query as your main parameter. Cuisine and diet parameters are optional",
	agent_id="TKAFFO7AR2",
	agent_version="DRAFT",
	function_arn="arn:aws:lambda:us-east-1:294090989896:function:agent-GetRecipesFunction-53W7zP0YIFTU",
	function_schema={
				"functions": [
					{	
						"description": "Fetch recipes based on user preferences.Use query parameter as your main input; ",
						"name": "getRecipes",
						"parameters": {
							"query": {
								"description": "short and crisp natural language query from the user. e.g. If the user says 'I want to cook a chicken curry', the query is 'chicken curry'. if user asks for Jamaican recipes, set query as Jamaican recipes",
								"type": "string",
								"required": True
							}
						}, 
						"requireConfirmation": "DISABLED"
					}
				]
			}
)

print(response)