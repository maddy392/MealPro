import { defineFunction, secret } from "@aws-amplify/backend";

export const fetchRecipes = defineFunction({
	name: "fetchRecipes",
	entry: "src/fetchRecipes.ts",
	environment: {
		SPOONACULAR_RAPIDAPI_KEY: secret("SPOONACULAR_RAPIDAPI_KEY"),
	}
})