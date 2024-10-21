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
    @Published var favoriteRecipeIds: Set<String> = []
    
    init() {
        Task {
            await fetchUserFavorites()
        }
    }
    
    func fetchUserFavorites() async {
        
        do {
            let userId = try await Amplify.Auth.getCurrentUser().userId
            guard let queriedUser = try await Amplify.API.query(request: .get(User.self, byIdentifier: .identifier(userId: userId))).get() else {
                print("User not found")
                return
            }
            
            print("Queried User: \(queriedUser.username)")
            
            if let userFavorites = queriedUser.favorites {
                try await userFavorites.fetch()
                print("User's Favorite Recipes: \(userFavorites)")
            } else {
                print("User has no favorite recipes")
            }
        } catch {
            print("Failed to fetch user or their favorite recipes: \(error)")
        }
    }
    
    func toggleFavoriteStatus(for recipe: Recipe) async {
        do {
            let currentUser = try await Amplify.Auth.getCurrentUser()
            let user = User(userId: currentUser.username, username: currentUser.userId)
            
            if isFavorited(recipeId: recipe.recipeId) {
                // Unfavorite Recipe
                await unFavoriteRecipe(recipe: recipe, user: user)
            } else {
                // Favorite Recipe
                await favoriteRecipe(recipe: recipe, user: user)
            }
        } catch {
            
        }
    }
    
    func isFavorited(recipeId: String) -> Bool {
        return favoriteRecipeIds.contains(recipeId)
    }
    
    private func unFavoriteRecipe(recipe: Recipe, user: User) async {
       
        let currentUser = try! await Amplify.Auth.getCurrentUser()
        let user = User(userId: currentUser.username, username: currentUser.userId)
        do {
            let userFavoriteResponse = try await Amplify.API.query(request: .list(UserFavorite.self, where: UserFavorite.keys.user.eq(user as! EnumPersistable).and(UserFavorite.keys.recipe.eq(recipe as! EnumPersistable))))
            
            let userFavorite = userFavoriteResponse else {
                print("UserFavorite not found")
                return
            }
        }
        
    }
    
    private func favoriteRecipe(recipe: Recipe, user: User) async {
        do {
            let userFavorite = UserFavorite(recipe: recipe, user: user)
            let result = try await Amplify.API.mutate(request: .create(userFavorite))
            
            switch result {
            case .success(let newUserFavorite):
                DispatchQueue.main.async {
                    self.favoriteRecipeIds.insert(recipe.recipeId)
                }
                print("Favorited recipe: \(recipe) for user \(user)")
            case .failure(let error):
                print("Failed to favorite recipe: \(error.errorDescription)")
            }
        } catch {
            print("Error favoriting recipe: \(error)")
        }
    }
}
