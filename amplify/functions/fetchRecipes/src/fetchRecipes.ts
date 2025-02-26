import type { Handler } from "aws-lambda";
import type { Schema } from "../../../data/resource";
import { env } from '$amplify/env/listRecipes';

export const handler: Schema["fetchRecipes"]["functionHandler"] = async (event, context) => {

	let cuisine = "";
  	let diet = "";

	if ("arguments" in event) {
		cuisine = event.arguments.cuisine || "";
		diet = event.arguments.diet || "";
	}

	try {
		const url = new URL('https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com/recipes/complexSearch');
		url.searchParams.set('cuisine', cuisine);
		url.searchParams.set('diet', diet);
		url.searchParams.append('sort', 'popularity');
		url.searchParams.append('addRecipeInformation', 'true');
		url.searchParams.append('addRecipeNutrition', 'true');
		url.searchParams.append('instructionsRequired', 'true');

		const response = await fetch(url.toString(), {
			headers: {
				'X-RapidAPI-Key': env.SPOONACULAR_RAPIDAPI_KEY,
			},
		});

		if (!response.ok) {
			throw new Error(`HTTP error! status: ${response.status}`);
		}

		const data = await response.json();
		console.log(data);

		// Filter out recipes where analyzedInstructions is an empty array
		const filteredRecipes = data.results.filter((recipe: any) => 
			Array.isArray(recipe.analyzedInstructions) && recipe.analyzedInstructions.length > 0
		);

		const recipes = filteredRecipes.map((recipe: any) => {
			const { id, ...rest } = recipe;
			return { recipeId: id, ...rest };
		});
		console.log(recipes);
		return recipes;
	} catch (error) {
			console.error('Error fetching recipes:', error);
			throw error;
		}
};