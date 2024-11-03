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

		const response = await fetch(url.toString(), {
			headers: {
				'X-RapidAPI-Key': env.SPOONACULAR_RAPIDAPI_KEY,
			},
		});

		if (!response.ok) {
			throw new Error(`HTTP error! status: ${response.status}`);
		}

		const data = await response.json();
		const recipes = data.results.map((recipe: any) => ({
			recipeId: recipe.id,
			title: recipe.title,
			image: recipe.image,
			imageType: recipe.imageType,
		}));
		return recipes;
	} catch (error) {
			console.error('Error fetching recipes:', error);
			throw error;
		}
};