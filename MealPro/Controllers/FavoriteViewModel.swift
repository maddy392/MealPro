//
//  RecipeViewModel.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import Amplify
import SwiftUI


@MainActor
class FavoriteViewModel: ObservableObject {
    @Published var userFavorites: [UserFavoriteWithRecipeItem] = []
    private var favoriteRecipeIds: Set<Int> = []
    static let shared = FavoriteViewModel()
    
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
                  recipe {
                    recipeId
                    title
                    image
                    imageType
                  }
                }
              }
            }
            """
            
            let request = GraphQLRequest<UserFavoriteWithRecipeResponse>(
                document: document,
                responseType: UserFavoriteWithRecipeResponse.self,
                decodePath: operationName
            )
            
            let queriedUserFavorites = try await Amplify.API.query(request: request)
//            print(queriedUserFavorites)
            switch queriedUserFavorites {
            case .success(let userFavoriteResponse):
                DispatchQueue.main.async {
                    self.userFavorites = userFavoriteResponse.items
                    self.favoriteRecipeIds = Set(self.userFavorites.map { $0.recipe.recipeId })
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
            guard let userFavoriteToDelete = userFavorites.first(where: {$0.recipe.recipeId == recipe.recipeId }) else {
                print("No UserFavorite found for recipe: \(recipe.recipeId)")
                return
            }
            
            let operationName = "deleteUserFavorite"
            let document = """
              mutation DeleteUserFavorite($id: ID!) {
                \(operationName)(input: { id: $id }) {
                    id
                    recipeId
                  }
                }
            """
            
            let variables: [String: Any ] = ["id": userFavoriteToDelete.id]
            
            let request = GraphQLRequest<UserFavoriteItem>(
                document: document,
                variables: variables,
                responseType: UserFavoriteItem.self,
                decodePath: operationName
            )
            
            let deleteResponse = try await Amplify.API.mutate(request: request)
            
            switch deleteResponse {
            case .success(let deletedFavorite):
                DispatchQueue.main.async {
                    self.userFavorites.removeAll(where: {$0.id == deletedFavorite.id})
                    self.favoriteRecipeIds.remove(deletedFavorite.recipeId)
                }
                print("Successfully unfavorited recipe with ID: \(deletedFavorite.recipeId)")
            case .failure(let error):
                print("Failed to unfavorite recipe: \(error.errorDescription)")
            }
        } catch {
            print("Error in unfavoriting recipe: \(error)")
        }
    }
    
    func isFavorited(recipeId: Int) -> Bool {
        return favoriteRecipeIds.contains(recipeId)
    }
    
    func favorite(recipe: Recipe) async {
        print("Attempting to favorite recipe: \(recipe.id): \(recipe.title)")
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
//            print(recipeResponse)
            
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
            
            // Step 3: get user
            let opName = "createUserFavorite"
            let createUserFavoriteQuery = """
                mutation CreateUserFavorite($recipeId: Int!, $userId: ID!) {
                  \(opName)(input: {recipeId: $recipeId, userId: $userId}) {
                    id
                    recipeId
                  }
                }
                """
                
                let vars: [String: Any] = [
                    "recipeId": existingRecipe.recipeId,
                    "userId": userId
                ]
            
            let graphqlRequest = GraphQLRequest<UserFavoriteItem>(
                document: createUserFavoriteQuery,
                variables: vars,
                responseType: UserFavoriteItem.self,
                decodePath: opName
            )
            
            // step 5: create userFavorite in the backend
            let favoriteResponse = try await Amplify.API.mutate(request: graphqlRequest)
            
            switch favoriteResponse {
            case .success(let favorite):
                DispatchQueue.main.async {
                    self.userFavorites.append(UserFavoriteWithRecipeItem(id: favorite.id, recipe: existingRecipe))
                    self.favoriteRecipeIds.insert(favorite.recipeId)
                }
                print("Successfully favorited recipe: \(favorite.recipeId)")
            case .failure(let error):
                print("Failed to favorite recipe: \(error.errorDescription)")
            }
        } catch {
            print("Error favoriting recipe: \(error)")
        }
    }
}
