import json
import boto3
import requests


def lambda_handler(event, context):
    ssm = boto3.client('ssm')
    parameter_name = '/amplify/mealpro/madpro-sandbox-6e21c0feec/SPOONACULAR_RAPIDAPI_KEY'
    
    response = ssm.get_parameter(Name=parameter_name, WithDecryption=True)
    api_key = response['Parameter']['Value']
    # print(api_key)

    agent = event['agent']
    actionGroup = event['actionGroup']
    function = event['function']
    parameters = event.get('parameters', [])

    recipe_id = next((param["value"] for param in parameters if param["name"] == "recipeId"), None)
    number = next((param["value"] for param in parameters if param["name"] == "number"), 3)  # Default to 3 if not provided
    
    # Use the api_key in your function logic
    similar_recipes_url = f"https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/{recipe_id}/similar?number={number}"

    # params['instructionsRequired'] = True
    # params['addRecipeInformation'] = True
    # params['number'] = 3
    # params["sort"] = "popularity"
    headers = {
    'X-RapidAPI-Key': api_key, 
    "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    }
    
    try:
        similar_recipes_response = requests.get(similar_recipes_url, headers=headers)
        similar_recipes_response.raise_for_status()
        similar_recipes = similar_recipes_response.json()

        # Extract the IDs
        recipe_ids = [str(recipe['id']) for recipe in similar_recipes]
        if not recipe_ids:
            return {
                "messageVersion": "1.0",
                "response": {
                    "actionGroup": actionGroup,
                    "function": function,
                    "functionResponse": {
                        "responseBody": {
                            "TEXT": {
                                "body": "No similar recipes found."
                            }
                        }
                    }
                }
            }

        # Fetch details of the similar recipes
        info_url = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/informationBulk"
        querystring = {"ids": ",".join(recipe_ids)}
        detailed_response = requests.get(info_url, headers=headers, params=querystring)
        detailed_response.raise_for_status()
        detailed_recipes = detailed_response.json()

        # Filter the detailed recipes to include only required keys
        required_keys = [
            "id", "title", "image", "imageType", "vegetarian", "vegan", "glutenFree", "dairyFree",
            "healthScore", "readyInMinutes"
        ]
        modified_recipes = [
            {k: recipe[k] for k in required_keys if k in recipe}
            for recipe in detailed_recipes
        ]

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

        
    except requests.exceptions.RequestException as e:
        return {
            "messageVersion": "1.0",
            "response": {
                "actionGroup": actionGroup,
                "function": function,
                "functionResponse": {
                    "responseBody": {
                        "TEXT": {
                            "body": f"Error fetching similar recipes: {str(e)}"
                        }
                    }
                }
            }
        }
