//
//  ResponseSchemas.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/27/24.
//
struct GetRecipeResponse: Decodable {
    let getRecipe: Recipe?
}

struct UserFavoriteItem: Decodable {
    let id: String
    let recipeId: Int
}

struct UserFavoritesResponse: Decodable {
    let items: [UserFavoriteItem]
    let nextToken: String?
}
