//
//  RecipeListView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//
import SwiftUI
import Amplify

let staticRecipes = [
    Recipe(recipeId: 644387, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-312x231.jpg"),
    Recipe(recipeId: 635081, title: "Black Beans & Brown Rice With Garlicky Kale", image: "https://img.spoonacular.com/recipes/635081-312x231.jpg"),
    Recipe(recipeId: 644390, title: "Garlicky Roasted Kale", image: "https://img.spoonacular.com/recipes/644390-312x231.jpg")
]

struct RecipeListView: View {

    @EnvironmentObject private var favoriteViewModel: FavoriteViewModel
    @State private var recipes = staticRecipes

    var body: some View {
        List {
            ForEach($recipes, id: \.recipeId) { $recipe in  // Use recipes, not $recipes
                RecipeView(recipe: recipe)
            }
        }
        .onAppear {
            Task {
                await favoriteViewModel.fetchUserFavorites()
            }
        }
    }
}

//#Preview {
//    R
//}
