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
    
    # Use the api_key in your function logic
    url = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch"

    params = {item["name"]:item["value"] for item in parameters}
    params['instructionsRequired'] = True
    params['addRecipeInformation'] = True
    params['number'] = 3
    params["sort"] = "popularity"
    headers = {
    'X-RapidAPI-Key': api_key
    }
    required_keys = ["id", "title", "image", "imageType", "vegetarian", "vegan", "glutenFree", "dairyFree",
    "healthScore", "readyInMinutes"]

    response = requests.request("GET", url, headers=headers, params=params)

    recipe_results = response.json()['results']
    modified_recipes = [{**{k if k != 'id' else 'recipeId': v for k, v in recipe.items() if k in required_keys}} for recipe in recipe_results]


    return {
    "messageVersion": "1.0",
    "response": {
        "actionGroup": actionGroup,
        "function": function,
        "functionResponse": {
            "responseBody": {
                "TEXT": { 
                    "body": json.dumps(modified_recipes)
                }
            }
        }
    },
    "sessionAttributes": {
        "string": "string",
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
        },
    ]
}
