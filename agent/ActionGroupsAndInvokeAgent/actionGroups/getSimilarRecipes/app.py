import json
import boto3
import requests


def lambda_handler(event, context):
    # ssm = boto3.client('ssm')
    # parameter_name = '/amplify/mealpro/madpro-sandbox-6e21c0feec/SPOONACULAR_RAPIDAPI_KEY'
    
    # response = ssm.get_parameter(Name=parameter_name, WithDecryption=True)
    # api_key = response['Parameter']['Value']
    # print(api_key)
    bedrock_agent_runtime_client = boto3.client('bedrock-agent-runtime')

    agent = event['agent']
    actionGroup = event['actionGroup']
    function = event['function']
    parameters = event.get('parameters', [])
    print(event)
    # knowledge_base_id="WGVGYSRSZJ"
    knowledge_base_id = event.get("sessionAttributes", {}).get("knowledgeBaseId", "")


    recipe_id = next((param["value"] for param in parameters if param["name"] == "recipeId"), None)
    if recipe_id is not None:
        try:
            recipe_id = int(recipe_id)  # Convert to integer
        except ValueError:
            raise ValueError(f"Invalid recipeId: {recipe_id}. It must be a numeric value.")

    if not recipe_id:
        return {
            "messageVersion": "1.0",
            "response": {
                "actionGroup": event['actionGroup'],
                "function": event['function'],
                "functionResponse": {
                    "responseBody": {
                        "TEXT": {"body": "recipeId parameter is required."}
                    }
                }
            }
        }
    
    # Get original recipe by recipe_id
    recipe_id_filter = {
        "equals": {
            "key": "recipe_id",
            "value": recipe_id
            }
        }

    response = bedrock_agent_runtime_client.retrieve(
        knowledgeBaseId=knowledge_base_id,
        retrievalQuery={"text": "recipe"},
        retrievalConfiguration={
            "vectorSearchConfiguration": {
                "numberOfResults": 1,
                "filter": recipe_id_filter
            }
        }
    )
    original_recipe = response['retrievalResults'][0]['metadata']
    original_title = original_recipe['title']
    original_ingredients = ", ".join(
        sorted(original_recipe['ingredients'])
    )
    # print(original_recipe , original_title, original_ingredients)
    # print(original_recipe["dishTypes"], original_recipe["cuisines"])

    title_response = bedrock_agent_runtime_client.retrieve(
        knowledgeBaseId=knowledge_base_id,
        retrievalQuery={"text": original_title},
        retrievalConfiguration={
            "vectorSearchConfiguration": {
                "numberOfResults": 2,
                "overrideSearchType": "HYBRID", 
                "filter": {
                    "notEquals": {
                        "key": "recipe_id",
                        "value": recipe_id
                    }
                }
            }
        }
    )
    # print(title_response)

    ingredients_response = bedrock_agent_runtime_client.retrieve(
        knowledgeBaseId=knowledge_base_id,
        retrievalQuery={"text": original_ingredients},
        retrievalConfiguration={
            "vectorSearchConfiguration": {
                "numberOfResults": 2,
                "overrideSearchType": "HYBRID", 
                "filter": {
                    "notEquals": {
                        "key": "recipe_id",
                        "value": recipe_id
                    }
                }
            }
        }
    )
    # print(ingredients_response)

    # Combine and exclude the original recipe
    retrieved_recipes = title_response['retrievalResults'] + ingredients_response['retrievalResults']

    # Filter the detailed recipes to include only required keys
   # Define required keys
    required_keys = ["recipe_id", "title", "image", "imageType", "vegetarian", "vegan", "glutenFree", "dairyFree",
                     "healthScore", "readyInMinutes", "cuisines", "dishTypes"]
    # Process the retrieved documents and format as per required_keys
    modified_recipes = []
    for retrieved_doc in retrieved_recipes:
        metadata = retrieved_doc["metadata"]
        recipe_data = {
        "recipeId" if k == "recipe_id" else k: int(metadata.get(k)) if k == "recipe_id" else metadata.get(k)
        for k in required_keys
        }       
        modified_recipes.append(recipe_data)

    return {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": actionGroup,
            "function": function,
            "functionResponse": {
                "responseBody": {
                    "TEXT": {"body": json.dumps(modified_recipes)}
                }
            }
        }
    }