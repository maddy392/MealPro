//
//  RecipeViewModel.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import Amplify
import SwiftUI

struct PaginatedList<ModelType: Model>: Decodable {
    let items: [ModelType]
    let nextToken: String?
    let id: String?
}


@MainActor
class FavoriteViewModel: ObservableObject {
    @Published var userFavorites: [UserFavoriteItem] = []
    private var favoriteRecipeIds: Set<Int> = []
    
    init() {
        Task {
            await fetchUserFavorites()
        }
    }
    
    func fetchUserFavorites() async {
        
        do {
            let userId = try await Amplify.Auth.getCurrentUser().userId
            let operationName = "userFavoritesByUser"
            let document = """
            query userFavoritesByUser {
            \(operationName)(userId: "\(userId)") {
              nextToken
                items {
                  id
                  recipeId
                }
              }
            }
            """
            
            let request = GraphQLRequest<UserFavoritesResponse>(
                document: document,
                responseType: UserFavoritesResponse.self,
                decodePath: operationName
            )
            
            let queriedUserFavorites = try await Amplify.API.query(request: request)
//            print(queriedUserFavorites)
            switch queriedUserFavorites {
            case .success(let userFavoriteResponse):
                DispatchQueue.main.async {
                    self.userFavorites = userFavoriteResponse.items
                    self.favoriteRecipeIds = Set (self.userFavorites.compactMap { $0.recipeId })
                }
                print("Favorite Recipe IDs: \(favoriteRecipeIds)")
            case .failure(let error):
                print("Failed to getch user favorites: \(error)")
            }
        } catch {
            print("Failed to fetch user or their favorite recipes: \(error)")
        }
    }
    
    func toggleFavoriteStatus(for recipe: Recipe) async {
        if isFavorited(recipeId: recipe.recipeId) {
            await unFavorite(recipe: recipe)
        } else {
            await favorite(recipe: recipe)
        }
    }
    
    func unFavorite(recipe: Recipe) async {
        do {
            guard let userFavoriteToDelete = userFavorites.first(where: {$0.recipeId == recipe.recipeId }) else {
                print("No UserFavorite found for recipe: \(recipe.recipeId)")
                return
            }
            
            let deleteRequest = GraphQLRequest<DeleteUserFavoriteResponse>
            
        } catch {
            print("pass")
        }
    }
    
    func isFavorited(recipeId: Int) -> Bool {
        return favoriteRecipeIds.contains(recipeId)
    }
    
    func favorite(recipe: Recipe) async {
        print("Attempting to favorite recipe: \(recipe)")
        do {
            // Step 1: Fetch current User
            let userId = try await Amplify.Auth.getCurrentUser().userId
            
            // Step 2: Check if recipe exists in database
            var existingRecipe: Recipe
            let operationName = "getRecipe"
            let document = """
                query GetRecipeByRecipeId($recipeId: Int!) {
                  \(operationName)(recipeId: $recipeId) {
                    recipeId
                    title
                  }
                }
            """
            
            let variables: [String: Any ] = ["recipeId": recipe.recipeId]
            
            let request = GraphQLRequest<GetRecipeResponse>(document: document, variables: variables, responseType: GetRecipeResponse.self)
            let recipeResponse = try await Amplify.API.query(request: request)
            print(recipeResponse)
            
            switch recipeResponse {
            case .success(let fetchedRecipe):
                if let fetchedRecipe = fetchedRecipe.getRecipe {
                    existingRecipe = fetchedRecipe
                    print("Recipe Found")
                } else {
                    let newRecipe = Recipe(
                        recipeId: recipe.recipeId,
                        title: recipe.title,
                        image: recipe.image,
                        imageType: recipe.imageType
                    )
                    
                    let createdRecipeResponse = try await Amplify.API.mutate(request: .create(newRecipe))
                    switch createdRecipeResponse {
                    case .success(let createdRecipe):
                        existingRecipe = createdRecipe
                        print("Successfully created new recipe: \(createdRecipe.title)")
                    case .failure(let error):
                        print("Failed to create recipe: \(error.errorDescription)")
                        return
                    }
                }
            case .failure(let error):
                print("Failed to check if recipe exists or not: \(error)")
                return
            }
            
//             Step 3: get user
            guard let userResponse = try await Amplify.API.query(request: .get(User.self, byIdentifier: .identifier(userId: userId))).get() else {
                print("User not found")
                return
            }
            
            // Step 4: Create UserFavorite with full User and Recipe objects
            let newUserFavorite = UserFavorite(
                recipe: existingRecipe,
                user: userResponse
            )
            print(newUserFavorite)
            
            // step 5: create userFavorite in the backend
            let favoriteResponse = try await Amplify.API.mutate(request: .create(newUserFavorite))
            switch favoriteResponse {
            case .success(let favorite):
//                DispatchQueue.main.async {
//                    self.userFavorites.append(favorite)
//                }
                print("Successfully favorited recipe: \(favorite)")
            case .failure(let error):
                print("Failed to favorite recipe: \(error.errorDescription)")
            }
        } catch {
            print("Error favoriting recipe: \(error)")
        }
    }
}
