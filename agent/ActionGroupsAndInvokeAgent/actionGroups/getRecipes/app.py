import boto3
import json

def lambda_handler(event, context):

    print(event)

    # Extract parameters from the event
    parameters = {param["name"]: param["value"] for param in event.get('parameters', [])}
    query = parameters.get("query", "recipes")
    dishType = parameters.get("dishType", None)
    ingredients = parameters.get("ingredients", [])
    cuisine = parameters.get("cuisine", [])
    vegetarian = parameters.get("vegetarian", None)
    vegan = parameters.get("vegan", None)
    glutenFree = parameters.get("glutenFree", None)
    dairyFree = parameters.get("dairyFree", None)
    healthScore = parameters.get("healthScore", None)
    readyInMinutes = parameters.get("readyInMinutes", None)
    kb_id_standard = event.get("sessionAttributes", {}).get("knowledgeBaseId", "")
    # print(f"kb id: {}")

    # Set knowledge base ID
    # kb_id_standard = "WGVGYSRSZJ"

    # Normalize the cuisine input
    try:
        if isinstance(cuisine, str):
            if cuisine.startswith("[") and cuisine.endswith("]"):
                # Replace single quotes with double quotes to make it valid JSON
                cuisine = cuisine.replace("'", '"')
                # Parse the JSON string into a list
                cuisine = json.loads(cuisine)
            elif "," in cuisine:  # Handle comma-separated string
                cuisine = [c.strip() for c in cuisine.split(",")]
            else:
                cuisine = [cuisine] if cuisine else []
        else:
            cuisine = []  # Default to empty list if not a string
    except Exception as e:
        raise ValueError(f"Error processing cuisine: {cuisine}. Error: {str(e)}")

    # Normalize the ingredients input
    try:
        if isinstance(ingredients, str):
            if ingredients.startswith("[") and ingredients.endswith("]"):
                # Replace single quotes with double quotes to make it valid JSON
                ingredients = ingredients.replace("'", '"')
                # Parse the JSON string into a list
                ingredients = json.loads(ingredients)
            elif "," in ingredients:  # Handle comma-separated string
                ingredients = [i.strip() for i in ingredients.split(",")]
            else:
                ingredients = [ingredients] if ingredients else []
        else:
            ingredients = []  # Default to empty list if not a string
    except Exception as e:
        raise ValueError(f"Error processing ingredients: {ingredients}. Error: {str(e)}")

    # Build individual conditions
    conditions = []

    if dishType:
        conditions.append({
            "listContains": {
                "key": "dishTypes",
                "value": dishType
            }
        })

    if ingredients:
        print(ingredients)
        for ingredient in ingredients:
            print(ingredient)
            conditions.append({
                "stringContains": {
                    "key": "ingredients",
                    "value": ingredient.strip()
                }
            })

    if cuisine:
        if len(cuisine) > 1:
            # Add an `orAll` condition for multiple cuisines
            conditions.append({
                "orAll": [
                    {
                        "listContains": {
                            "key": "cuisines",
                            "value": c.strip()
                        }
                    }
                    for c in cuisine
                ]
            })
        elif len(cuisine) == 1:
            # Use `listContains` directly if only one cuisine is provided
            conditions.append({
                "listContains": {
                    "key": "cuisines",
                    "value": cuisine[0]
                }
            })

    # Normalize healthScore and dietary preferences
    try:
        if healthScore is not None:
            healthScore = int(healthScore)  # Convert string to integer
    except ValueError:
        raise ValueError(f"Invalid value for healthScore: {healthScore}")
    
    try:
        if readyInMinutes is not None:
            readyInMinutes = int(readyInMinutes)  # Convert string to integer
    except ValueError:
        raise ValueError(f"Invalid value for healthScore: {readyInMinutes}")

    if vegetarian is not None:
        vegetarian = vegetarian.lower() == "true"  # Convert to boolean

    if vegan is not None:
        vegan = vegan.lower() == "true"  # Convert to boolean

    if glutenFree is not None:
        glutenFree = glutenFree.lower() == "true"  # Convert to boolean

    if dairyFree is not None:
        dairyFree = dairyFree.lower() == "true"  # Convert to boolean
    
    if vegetarian is not None:
        conditions.append({
            "equals": {
                "key": "vegetarian",
                "value": vegetarian
            }
        })

    if vegan is not None:
        conditions.append({
            "equals": {
                "key": "vegan",
                "value": vegan
            }
        })

    if glutenFree is not None:
        conditions.append({
            "equals": {
                "key": "glutenFree",
                "value": glutenFree
            }
        })

    if dairyFree is not None:
        conditions.append({
            "equals": {
                "key": "dairyFree",
                "value": dairyFree
            }
        })

    if healthScore:
        conditions.append({
            "greaterThan": {
                "key": "healthScore",
                "value": healthScore
            }
        })

    if readyInMinutes:
        conditions.append({
            "lessThan": {
                "key": "readyInMinutes",
                "value": readyInMinutes
            }
        })

    # Build the final filter based on the number of conditions
    if len(conditions) >= 2:
        one_group_filter = {"andAll": conditions}
    elif len(conditions) == 1:
        # If there's only one condition, use it directly
        one_group_filter = conditions[0]
    else:
        # Handle the case where there are no conditions (e.g., default filter)
        one_group_filter = {}

    print(one_group_filter)

    # Build the final retrieval configuration
    retrieval_configuration = {
        "vectorSearchConfiguration": {
            "numberOfResults": 3
        }
    }

    if len(conditions) >= 2:
        retrieval_configuration["vectorSearchConfiguration"]["filter"] = {"andAll": conditions}
    elif len(conditions) == 1:
        retrieval_configuration["vectorSearchConfiguration"]["filter"] = conditions[0]

    # Initialize Bedrock client
    bedrock_agent_runtime_client = boto3.client('bedrock-agent-runtime')

    # Attempt to make the API call
    try:
        response = bedrock_agent_runtime_client.retrieve(
            knowledgeBaseId=kb_id_standard,
            retrievalQuery={"text": query},
            retrievalConfiguration=retrieval_configuration
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