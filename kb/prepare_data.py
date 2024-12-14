import boto3
import requests
import os
import json
import pandas as pd
import time


# Set AWS profile and region
os.environ['AWS_PROFILE'] = 'mealPro'
os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'

session = boto3.session.Session(profile_name="mealPro", region_name="us-east-1")
ssm = session.client('ssm')
parameter_name = '/amplify/mealpro/madpro-sandbox-6e21c0feec/SPOONACULAR_RAPIDAPI_KEY'

response = ssm.get_parameter(Name=parameter_name, WithDecryption=True)
api_key = response['Parameter']['Value']

# Use the api_key in your function logic
url = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch"

params = {}
params['query'] = ""
params['instructionsRequired'] = True
params['addRecipeInformation'] = True
params['addRecipeNutrition'] = True
params['number'] = 100
params["sort"] = "random"
headers = {
'X-RapidAPI-Key': api_key
}


def flatten_recipe_data(data):
    recipes = []
    for recipe in data["results"]:
        flattened_recipe = {
            "id": recipe.get("id"),
            "title": recipe.get("title"),
            "vegetarian": recipe.get("vegetarian"),
            "vegan": recipe.get("vegan"),
            "glutenFree": recipe.get("glutenFree"),
            "dairyFree": recipe.get("dairyFree"),
            "veryHealthy": recipe.get("veryHealthy"),
            "cheap": recipe.get("cheap"),
            "veryPopular": recipe.get("veryPopular"),
            "sustainable": recipe.get("sustainable"),
            "lowFodmap": recipe.get("lowFodmap"),
            "weightWatcherSmartPoints": recipe.get("weightWatcherSmartPoints"),
            "healthScore": recipe.get("healthScore"),
            "pricePerServing": recipe.get("pricePerServing"),
            "readyInMinutes": recipe.get("readyInMinutes"),
            "servings": recipe.get("servings"),
            "sourceName": recipe.get("sourceName"),
            "sourceUrl": recipe.get("sourceUrl"),
            "cuisines": ", ".join(recipe.get("cuisines", [])),
            "dishTypes": ", ".join(recipe.get("dishTypes", [])),
            "ingredients": ", ".join(
                f"{ingredient['name']} ({ingredient['amount']} {ingredient['unit']})"
                for ingredient in recipe.get("nutrition", {}).get("ingredients", [])
            ),
            "analyzedInstructions": " ".join(
                step["step"] for instruction in recipe.get("analyzedInstructions", [])
                for step in instruction.get("steps", [])
            ), 
			"percentProtein": recipe.get('nutrition').get("caloricBreakdown").get("percentProtein", 0),
			"percentFat": recipe.get('nutrition').get("caloricBreakdown").get("percentFat", 0),
			"percentCarbs": recipe.get('nutrition').get("caloricBreakdown").get("percentCarbs", 0)

        }
        
        # Add nutritional elements as separate columns
        for nutrient in recipe.get("nutrition", {}).get("nutrients", []):
            flattened_recipe[f"{nutrient['name']}"] = nutrient.get("amount")
        
		# Add nutritional elements as separate columns
        for property_ in recipe.get("nutrition", {}).get("properties", []):
            flattened_recipe[f"{property_['name']}"] = property_.get("amount")
        
        recipes.append(flattened_recipe)
    
    return recipes

# Example function to process API response and save to CSV
def append_recipes_to_csv(api_response, output_file=None):
	new_recipes = flatten_recipe_data(api_response)
	new_df = pd.DataFrame(new_recipes)

	if os.path.exists(output_file):
		existing_df = pd.read_csv(output_file)
		existing_ids = set(existing_df['id'])
		new_df = new_df[~new_df['id'].isin(existing_ids)]
		combined_df = pd.concat([existing_df, new_df], ignore_index=True)
	else:
		combined_df = new_df

	# Save the combined DataFrame to the CSV
	combined_df.to_csv(output_file, index=False)
	print(f"Updated CSV with {len(new_df)} new recipes. Total recipes: {len(combined_df)}.")


for _ in range(50):
	time.sleep(2)
	response = requests.request("GET", url, headers=headers, params=params)
	data = json.loads(response.text)
	append_recipes_to_csv(data, "all_recipes.csv")