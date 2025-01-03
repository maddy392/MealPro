import boto3
import json

def lambda_handler(event, context):

    print(event)

    # Extract parameters from the event
    parameters = {param["name"]: param["value"] for param in event.get('parameters', [])}
    query = parameters.get("query", "recipes")
    dishType = parameters.get("dishType", None)
    ingredients = parameters.get("ingredients", [])
    cuisine = parameters.get("cuisine", None)

    # Normalize the ingredients input
    if ingredients:
        # If ingredients is a comma-separated string, split it into a list
        if isinstance(ingredients, str):
            ingredients = ingredients.split(",")
        # If it's a single string (no commas), wrap it in a list
        elif isinstance(ingredients, list):
            pass  # Already a list, no action needed
        else:
            ingredients = [ingredients]  # Wrap single string or any other type in a list

    # Build the filter
    one_group_filter = {"andAll": []}

    if dishType:
        one_group_filter["andAll"].append({
            "listContains": {
                "key": "dishTypes",
                "value": dishType
            }
        })

    if ingredients:
        for ingredient in ingredients:
            one_group_filter["andAll"].append({
                "stringContains": {
                    "key": "ingredients",
                    "value": ingredient
                }
            })

    if cuisine:
        one_group_filter["andAll"].append({
            "listContains": {
                "key": "cuisines",
                "value": cuisine
            }
        })

    print(one_group_filter)

    # Initialize Bedrock client
    bedrock_agent_runtime_client = boto3.client('bedrock-agent-runtime')

    # Set knowledge base ID
    kb_id_standard = "CBMFQH60JT"

    # Attempt to make the API call
    try:
        response = bedrock_agent_runtime_client.retrieve(
            knowledgeBaseId=kb_id_standard,
            retrievalQuery={"text": query},
            retrievalConfiguration={
                "vectorSearchConfiguration": {
                    "numberOfResults": 5,
                    "filter": one_group_filter
                }
            }
        )
        # print(response["retrievalResults"])

    except Exception as e:
        # Handle API call failure
        error_message = {
            "error": str(e),
            "message": "Failed to fetch retrieval results. Please check your input and configuration."
        }
        print(error_message)
        return {
            "messageVersion": "1.0",
            "response": {
                "actionGroup": event.get("actionGroup", "defaultActionGroup"),
                "function": event.get("function", "defaultFunction"),
                "functionResponse": {
                    "responseBody": {
                        "TEXT": {
                            "body": json.dumps(error_message)
                        }
                    }
                }
            },
            "sessionAttributes": {},
            "promptSessionAttributes": {},
            "knowledgeBasesConfiguration": []
        }
    # print(response["retrievalResults"])

    # Define required keys
    required_keys = ["recipe_id", "title", "image", "imageType", "vegetarian", "vegan", "glutenFree", "dairyFree",
                     "healthScore", "readyInMinutes"]

    # Process the retrieved documents and format as per required_keys
    modified_recipes = []
    for retrieved_doc in response.get("retrievalResults", []):
        metadata = retrieved_doc["metadata"]
        recipe_data = {
        "recipeId" if k == "recipe_id" else k: int(metadata.get(k)) if k == "recipe_id" else metadata.get(k)
        for k in required_keys
        }       
        modified_recipes.append(recipe_data)

    print(modified_recipes)

    # Return the response
    return {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": event['actionGroup'],
            "function": event['function'],
            "functionResponse": {
                "responseBody": {
                    "TEXT": {
                        "body": json.dumps(modified_recipes, indent=4)
                    }
                }
            }
        },
        "sessionAttributes": {
            "string": "string"
        },
        "promptSessionAttributes": {
            "string": "string"
        },
        "knowledgeBasesConfiguration": [
            {
                "knowledgeBaseId": "string",
                "retrievalConfiguration": {
                    "vectorSearchConfiguration": {
                        "numberOfResults": 5
                    }
                }
            }
        ]
    }