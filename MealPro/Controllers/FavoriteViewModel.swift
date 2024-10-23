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
    @Published var userFavorites: [UserFavorite] = []
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
            
            let request = GraphQLRequest<PaginatedList<UserFavorite>>(
                document: document,
                responseType: PaginatedList<UserFavorite>.self,
                decodePath: operationName
            )
            
            let queriedUserFavorites = try await Amplify.API.query(request: request).get()
            print(queriedUserFavorites)
            DispatchQueue.main.async {
                self.userFavorites = queriedUserFavorites.items
//                self.favoriteRecipeIds = Set(queriedUserFavorites.compactMap { $0.recipeId })
            }
            await populateFavoriteRecipeIds()
        } catch {
            print("Failed to fetch user or their favorite recipes: \(error)")
        }
    }
    
    private func populateFavoriteRecipeIds() async {
        favoriteRecipeIds.removeAll()
        for favorite in userFavorites {
            if let recipe = try? await favorite.recipe {
                favoriteRecipeIds.insert(recipe.recipeId)
            }
        }
        print("Favorited Recipe IDs: \(favoriteRecipeIds)")
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
            // Step 1: Get the current user
            let currentUser = try await Amplify.Auth.getCurrentUser()

            // Step 2: Define the query to fetch UserFavorite by userId and recipeId (sort key)
            let operationName = "userFavoritesByUser"
            let document = """
            query UserFavoritesByUserAndRecipe {
              \(operationName)(userId: "\(currentUser.userId)", recipeId: \(recipe.recipeId)) {
                items {
                  id
                  recipeId
                }
              }
            }
            """
            
            // Step 3: Send the query to fetch the UserFavorite
            let request = GraphQLRequest<PaginatedList<UserFavorite>>(
                document: document,
                responseType: PaginatedList<UserFavorite>.self,
                decodePath: operationName
            )
            
            let queriedUserFavorites = try await Amplify.API.query(request: request).get()
            
            // Step 4: Ensure there is a UserFavorite to delete
            guard let userFavoriteToDelete = queriedUserFavorites.items.first else {
                print("No UserFavorite found for recipe: \(recipe.recipeId)")
                return
            }
            
            // Step 5: Delete the UserFavorite from the backend
            let deleteResult = try await Amplify.API.mutate(request: .delete(userFavoriteToDelete))
            
            switch deleteResult {
            case .success:
                // Step 6: Remove the UserFavorite from the local list and update the Set of favorited recipe IDs
                DispatchQueue.main.async {
                    self.userFavorites.removeAll { $0.id == userFavoriteToDelete.id }
                    self.favoriteRecipeIds.remove(recipe.recipeId)
                }
                print("Successfully unfavorited recipe with ID: \(recipe.recipeId)")
            case .failure(let error):
                print("Failed to unfavorite recipe: \(error.errorDescription)")
            }
            
        } catch {
            print("Error unfavoriting recipe: \(error)")
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
            let recipeResponse = try await Amplify.API.query(request: .get(Recipe.self, byIdentifier: .identifier(recipeId: recipe.recipeId)))
            print(recipeResponse)
            
            switch recipeResponse {
            case .success(let fetchedRecipe):
                if let fetchedRecipe = fetchedRecipe {
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
            
            // Step 3: get user
            guard let userResponse = try await Amplify.API.query(request: .get(User.self, byIdentifier: .identifier(userId: userId))).get() else {
                print("User not found")
                return
            }
            
            // Step 4: Create UserFavorite with full User and Recipe objects
            let newUserFavorite = UserFavorite(
                recipe: existingRecipe,
                user: userResponse
            )
            
            // step 5: create userFavorite in the backend
            let favoriteResponse = try await Amplify.API.mutate(request: .create(newUserFavorite))
            switch favoriteResponse {
            case .success(let favorite):
                DispatchQueue.main.async {
                    self.userFavorites.append(favorite)
                }
                print("Successfully favorited recipe: \(favorite)")
            case .failure(let error):
                print("Failed to favorite recipe: \(error.errorDescription)")
            }
        } catch {
            print("Error favoriting recipe: \(error)")
        }
    }
}
