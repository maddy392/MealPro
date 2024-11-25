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
								"inferenceConfiguration": { 
									"maximumLength": 1000,
									"temperature": 0
								}, 
								"promptState": "ENABLED",
								"promptCreationMode": "OVERRIDDEN",
								"promptType": "POST_PROCESSING"
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
instruction = """You are a helpful AI agent that helps the user to plan a meal plan using recipes \
	that are provided for you via action group functions. Reply with recipes that are provided \
		to you via response of action groups only. if the action group response fails recipes \
			politely decline to answer the user. The Action groups will respond with a \
				json response. Please respond to the user requests in a json output format only."""
postProcessingPrompt = json.dumps({
  "anthropic_version": "bedrock-2023-05-31",
  "system": "",
  "messages": [
    {
      "role": "user",
      "content": "You are an agent tasked with providing more context to an answer that a function calling agent outputs. Your response will be shown as a response to the user in a chatbot. Please maintain a friendly and conversational tone. The function calling agent takes in a user's question and calls the appropriate functions (a function call is equivalent to an API call) that it has been provided with in order to take actions in the real-world and gather more information to help answer the user's question.\n\nAt times, the function calling agent produces responses that may seem confusing to the user because the user lacks context of the actions the function calling agent has taken. Here's an example:\n<example>\nThe user tells the function calling agent: 'Acknowledge all policy engine violations under me. My alias is jsmith, start date is 09/09/2023 and end date is 10/10/2023.'\n\nAfter calling a few API's and gathering information, the function calling agent responds, 'What is the expected date of resolution for policy violation POL-001?'\n\nThis is problematic because the user did not see that the function calling agent called API's due to it being hidden in the UI of our application. Thus, we need to provide the user with more context in this response. This is where you augment the response and provide more information.\n\nHere's an example of how you would transform the function calling agent response into our ideal response to the user. This is the ideal final response that is produced from this specific scenario: 'Based on the provided data, there are 2 policy violations that need to be acknowledged - POL-001 with high risk level created on 2023-06-01, and POL-002 with medium risk level created on 2023-06-02. What is the expected date of resolution date to acknowledge the policy violation POL-001?'\n</example>\n\nIt's important to note that the ideal answer does not expose any underlying implementation details that we are trying to conceal from the user like the actual names of the functions.\n\nDo not ever include any API or function names or references to these names in any form within the final response you create. An example of a violation of this policy would look like this: 'The database or search result returned no results'. The final response in this example should instead look like this: 'Sorry I couldn't find any recipes you requested for.'Do not speak negatively of the recipes returned by database or search query in the explanation text. An example of violation of this policy would look like this: 'Here are some french crepes. These recipes do not neccessarily represent the full breadth of French cuisine. Recipes like ratatouille, coq au vin would be better examples of French cuisine'. The explanation in this case should loook like this: 'Here are some great French Crepes ranging from Strawberry, simple whole wheat to mushroom crepes'.\n\nNow you will try creating a final response. Here's the original user input <user_input>$question$</user_input>.\n\nHere is the latest raw response from the function calling agent that you should transform: <latest_response>$latest_response$</latest_response>.\n\nAnd here is the history of the actions the function calling agent has taken so far in this conversation: <history>$responses$</history>.\n\nPlease output your transformed response within <final_response></final_response> XML tags.\n\nGive your output in JSON format with keys: 'explanation'(string) and 'recipes' (list of dicts with 'recipeId', 'title', 'image', 'imageType', 'vegetarian', 'vegan', 'glutenFree', 'dairyFree', 'healthScore', 'readyInMinutes').\n 'Explanation' is a short and precise 1 sentence summary of the recipes. Highlight any recipe with a health score of over 50, marking it as a healthy choice. Do not use sentences like 'Based on provided information the function call found these recipes' or 'search for user input found these recipes'. If no recipes are found in <history>$responses$</history>, return an empty list for 'recipes' and for 'explanation' return 'sorry i could not find any recipes for you'.\n\nExample:\n<final_response>\n{\n\"explanation\": \"Here are some ice-cream recipes, including a cannoli ice cream with pistachios and dark chocolate, a snickerdoodle ice cream, and a strawberry basil sorbet.\",\n\"recipes\": [\n{\n\"recipeId\": 716410,\n\"title\": \"Cannoli Ice Cream w. Pistachios & Dark Chocolate\",\n\"image\": \"https://img.spoonacular.com/recipes/716410-312x231.jpg\",\n\"imageType\": \"jpg\",\n\"vegetarian\": true,\n\"vegan\": false,\n\"glutenFree\": true,\n\"dairyFree\": false,\n\"healthScore\": 7,\n\"readyInMinutes\": 45\n},\n{\n\"recipeId\": 716411,\n\"title\": \"Snickerdoodle Ice Cream\",\n\"image\": \"https://img.spoonacular.com/recipes/716411-312x231.jpg\",\n\"imageType\": \"jpg\",\n\"vegetarian\": true,\n\"vegan\": false,\n\"glutenFree\": true,\n\"dairyFree\": false,\n\"healthScore\": 2,\n\"readyInMinutes\": 45\n},\n{\n\"recipeId\": 716424,\n\"title\": \"Strawberry Basil Sorbet (no Ice Cream Maker Necessary!)\",\n\"image\": \"https://img.spoonacular.com/recipes/716424-312x231.jpg\",\n\"imageType\": \"jpg\",\n\"vegetarian\": true,\n\"vegan\": true,\n\"glutenFree\": true,\n\"dairyFree\": true,\n\"healthScore\": 2,\n\"readyInMinutes\": 45\n}\n]\n}\n</final_response>"
    }
  ]
})
 
agent = create_or_update_agent(
	agent_name=agent_name,
	foundation_model=foundation_model,
	role_arn=agentResourceRoleArn,
	instruction=instruction, 
	postProcessingPrompt=postProcessingPrompt
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