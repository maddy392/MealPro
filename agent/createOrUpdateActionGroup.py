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
    description="This Action Group fetches recipes based on user preferences. Use this action group even when "
        "the user provides no preferences, in which case call this action group with no parameters.",
    agent_id="TKAFFO7AR2",
    agent_version="DRAFT",
    function_arn="arn:aws:lambda:us-east-1:294090989896:function:agent-GetRecipesFunction-53W7zP0YIFTU",
    function_schema={
        "functions": [
            {
                "description": (
                    "Fetch recipes based on optional user preferences. Analyze user input to extract preferences using parameters: query (free-text, most versatile), ingredients, cuisine, dishType, and dietary or preparation filters. Use query generously for general or ambiguous input. Identify cuisine and dishType only if explicitly mentioned and ensure they match valid options: cuisine includes [Italian, Mexican, American, Asian, Chinese, Japanese, Indian, Mediterranean, French, Greek, Spanish, Thai, Korean, Vietnamese, Latin American, British, Caribbean, Cajun, German, Irish, African, European, Eastern European, Southern, Middle Eastern, Nordic, Jewish] and dishType includes [main course, side dish, dessert, appetizer, salad, bread, breakfast, soup, beverage, sauce, marinade, fingerfood, snack, drink]. If no explicit parameters are mentioned, use input entirely as query. For example, 'I want an Indian curry with chickpeas' maps to cuisine=Indian, ingredients=[chickpeas], and query=curry. For 'milkshakes', set query=milkshakes. For 'healthy', use healthScore > 50. For 'quick', use readyInMinutes < 30. Leave parameters blank if not mentioned."
                ),
                "name": "getRecipes",
                "parameters": {
                    "query": {
                        "description": (
                            "Short and crisp natural language query from the user. This is the only parameter that is free-text. "
                            "Use it generously. For example, if the user says 'I want to cook a chicken curry', the query is 'chicken curry'. "
                            "If the user asks for Jamaican recipes, set query as Jamaican recipes (as Jamaican is not allowed in parameter `cuisine`). "
                            "For 'milkshakes', set query=milkshakes."
                        ),
                        "type": "string",
                        "required": False
                    },
                    "ingredients": {
                        "description": (
                            "The ingredient list that the recipe the user has requested should contain. Ensure this parameter is an array. "
                            "For example, if the user asks for Kale Salad, ingredients=['kale']."
                        ),
                        "type": "array",
                        "required": False
                    },
                    "cuisine": {
                        "description": (
                            "The type of cuisine(s) the user is requesting. Stick to the following options: "
                            "[Italian, Mexican, American, Asian, Chinese, Japanese, Indian, Mediterranean, French, Greek, Spanish, "
                            "Thai, Korean, Vietnamese, Latin American, British, Caribbean, Cajun, German, Irish, African, European, "
                            "Eastern European, Southern, Middle Eastern, Nordic, Jewish]."
                        ),
                        "type": "array",
                        "required": False
                    },
                    "dishType": {
                        "description": (
                            "The type of dish the user is requesting. Stick to the following options: [main course, side dish, dessert, appetizer, "
                            "salad, bread, breakfast, soup, beverage, sauce, marinade, fingerfood, snack, drink]."
                        ),
                        "type": "string",
                        "required": False
                    },
                    "vegetarian": {
                        "description": "Whether the user prefers vegetarian recipes. Set to true if explicitly mentioned.",
                        "type": "boolean",
                        "required": False
                    },
                    "vegan": {
                        "description": "Whether the user prefers vegan recipes. Set to true if explicitly mentioned.",
                        "type": "boolean",
                        "required": False
                    },
                    "glutenFree": {
                        "description": "Whether the user prefers gluten-free recipes. Set to true if explicitly mentioned.",
                        "type": "boolean",
                        "required": False
                    },
                    "dairyFree": {
                        "description": "Whether the user prefers dairy-free recipes. Set to true if explicitly mentioned.",
                        "type": "boolean",
                        "required": False
                    },
                    "healthScore": {
                        "description": "Filter recipes by health score. For 'healthy' recipes, set healthScore > 50.",
                        "type": "integer",
                        "required": False
                    },
                    "readyInMinutes": {
                        "description": "Filter recipes by preparation time. For 'quick' recipes, set readyInMinutes < 30.",
                        "type": "integer",
                        "required": False
                    }
                },
                "requireConfirmation": "DISABLED"
            }
        ]
    }
)

print(response)

response = create_or_update_agent_action_group(
	name="getSimilarRecipesActionGroup",
	description="This Action Group fetches recipes similar to a given recipe as input. Pass on the recipeId as the main parameter;",
	agent_id="TKAFFO7AR2",
	agent_version="DRAFT",
	function_arn="arn:aws:lambda:us-east-1:294090989896:function:agent-GetSimilarRecipesFunction-VarpUrowz6gg",
	function_schema={
				"functions": [
					{	
						"description": "Fetch recipes similar to a given recipe. Use recipeId parameter as your main input; ",
						"name": "getSimilarRecipes",
						"parameters": {
							"recipeId": {
								"description": "The ID of the recipe for which you want to fetch similar recipes for",
								"type": "integer",
								"required": True
							}, 
							"number": {
								"description": "The number of similar recipes to fetch",
								"type": "integer",
								"required": False
							}
						}, 
						"requireConfirmation": "DISABLED"
					}
				]
			}
)

print(response)