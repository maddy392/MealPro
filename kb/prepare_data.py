import boto3
import requests
import os
import json
import pandas as pd
import time
import re

# initiate session, secret service manager client and fixed parameter name where spoonacular key is saved
session = boto3.session.Session(profile_name="mealPro", region_name="us-east-1")
ssm = session.client('ssm')
parameter_name = '/amplify/mealpro/madpro-sandbox-6e21c0feec/SPOONACULAR_RAPIDAPI_KEY'

# fetch api key
def fetch_api_key():
    response = ssm.get_parameter(Name=parameter_name, WithDecryption=True)
    return response['Parameter']['Value']

api_key = fetch_api_key()

# set up URL to call spoonacular api
url = "https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch"
headers = {
'X-RapidAPI-Key': api_key
}

def save_recipe_and_metadata(recipe, output_dir):

    # Prepare clean file name for the recipe
    recipe_name = sanitize_filename(recipe.get("title", "Unknown_Recipe"))
    recipe_file = os.path.join(output_dir, f"{recipe_name}.csv")
    metadata_file = os.path.join(output_dir, f"{recipe_name}.csv.metadata.json")

    # Prepare recipe file with one columns: title
    # recipe_data = pd.DataFrame([{"title": recipe.get("title", "Not available")}])
    recipe_data = pd.DataFrame([{
        "title": recipe.get("title", "Not available"),
        "ingredients": ", ".join(
            sorted(
                [f"{ingredient['name']} ({ingredient['amount']} {ingredient['unit']})" 
                                for ingredient in recipe.get("nutrition", {}).get("ingredients", [])] or ["Not available"]))
    }])
    recipe_data.to_csv(recipe_file, index=False, header=True)

    # Prepare metadata attributes
    metadata = {
        "metadataAttributes": {
            "Id": recipe_name,
            "title": recipe.get("title", "Not available"),
            "image": recipe.get("image", "Not available"),
            "imageType": recipe.get("imageType", "Not available"),
            "recipe_id": recipe["id"],
            "vegetarian": recipe.get("vegetarian", False),
            "vegan": recipe.get("vegan", False),
            "glutenFree": recipe.get("glutenFree", False),
            "dairyFree": recipe.get("dairyFree", False),
            "healthScore": recipe.get("healthScore", 0),
            "readyInMinutes": recipe.get("readyInMinutes", 0),
            "Calories": get_nutrient_value(recipe, "Calories"),
            "Fat": get_nutrient_value(recipe, "Fat"),
            "Carbohydrates": get_nutrient_value(recipe, "Carbohydrates"),
            "Cholesterol": get_nutrient_value(recipe, "Cholesterol"),
            "Protein": get_nutrient_value(recipe, "Protein"),
            "Glycemic Index": get_property_value(recipe, "Glycemic Index"),
            "ingredients": [
                f"{ingredient['name']} ({ingredient['amount']} {ingredient['unit']})"
                for ingredient in recipe.get("nutrition", {}).get("ingredients", [])
            ] or ["Not available"],
            "cuisines": recipe.get("cuisines", []) or ["Not available"],
            "dishTypes": recipe.get("dishTypes", []) or ["Not available"],
            "diets": recipe.get("diets", []) or ["Not available"]
        }
    }

    # Write metadata to JSON
    with open(metadata_file, "w") as metafile:
        json.dump(metadata, metafile, indent=4)

    # print(f"Recipe saved: {recipe_file}")
    # print(f"Metadata saved: {metadata_file}")

def get_nutrient_value(recipe, nutrient_name):
    """Retrieve a specific nutrient's value from the recipe or return '0'."""
    nutrients = recipe.get("nutrition", {}).get("nutrients", [])
    for nutrient in nutrients:
        if nutrient.get("name") == nutrient_name:
            return nutrient.get('amount')
    return 0

def get_property_value(recipe, property_name):
    """Retrieve a property value from the recipe or return 'Not available'."""
    properties = recipe.get("nutrition", {}).get("properties", [])
    for prop in properties:
        if prop.get("name") == property_name:
            return prop.get("amount", "0")
    return 0

def process_recipes_to_individual_csvs(api_response, output_dir):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    added_count = 0  # Counter for newly added recipes
    
    for recipe in api_response["results"]:
        recipe_name = sanitize_filename(recipe.get("title", "Unknown_Recipe"))
        recipe_file = os.path.join(output_dir, f"{recipe_name}.csv")
        metadata_file = os.path.join(output_dir, f"{recipe_name}.csv.metadata.json")
        
        # Skip if recipe or metadata already exists
        if os.path.exists(recipe_file) or os.path.exists(metadata_file):
            # print(f"Recipe '{recipe_name}' already exists. Skipping...")
            continue
        
        # Save recipe and metadata
        save_recipe_and_metadata(recipe, output_dir)
        added_count += 1  # Increment the count of added recipes
    
    total_recipes_after = len([f for f in os.listdir(output_dir) if f.endswith(".csv")])  # Count recipes after
    print(f"Added {added_count} recipes to folder, total recipes {total_recipes_after}")

# Function to sanitize file names
def sanitize_filename(title):
    return re.sub(r'[\/:*?"<>|\\()$,]', '_', title).replace(" ", "_")


def fetch_and_process_recipes(total_results, batch_size):
    """
    Fetch and process recipes from the Spoonacular API in batches, handling offset limits and switching sort.

    Args:
        total_results (int): Total number of recipes to fetch.
        batch_size (int): Number of recipes to fetch per batch.
    """
    params = {
        'query': "",
        'instructionsRequired': True,
        'addRecipeInformation': True,
        'addRecipeNutrition': True,
        'number': batch_size,
    }

    # Start fetching recipes
    offset = 0
    output_dir = "all_recipes_with_ingredients"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    saved_recipes = len([f for f in os.listdir(output_dir) if f.endswith(".csv")])
    sorting_phase = "popularity"

    while saved_recipes < total_results:
        if sorting_phase == "popularity":
            params['sort'] = "popularity"
            params['offset'] = offset
            print(f"Fetching popular recipes {offset + 1} to {offset + batch_size}...")
        else:
            params['sort'] = "random"
            if 'offset' in params:
                del params['offset']
            print(f"Fetching random recipes...")

        # Make API request
        response = requests.request("GET", url, headers=headers, params=params)

        if response.status_code == 200:
            data = json.loads(response.text)
            process_recipes_to_individual_csvs(data, output_dir)
            # Update the saved recipe count based on files in the folder
            saved_recipes = len([f for f in os.listdir(output_dir) if f.endswith(".csv")])
        else:
            print(f"Failed to fetch data: {response.status_code} - {response.text}")
            break  # Exit the loop if there's an error in the API response

        # Adjust offset for the popularity phase
        if sorting_phase == "popularity":
            offset += batch_size
            if offset >= 900 or saved_recipes >= 1000:
                print("Switching to random sorting...")
                sorting_phase = "random"

        time.sleep(2)  # Avoid hitting API rate limits

    print(f"All recipes have been fetched and saved. Total saved: {saved_recipes}")



if __name__ == "__main__":
    total_results = 10000  # Total number of recipes to fetch
    batch_size = 100  # Number of recipes to fetch per batch

    fetch_and_process_recipes(total_results, batch_size)
