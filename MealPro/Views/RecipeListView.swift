//
//  RecipeListView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//
import SwiftUI
import Amplify

let staticRecipes = [
    Recipe(recipeId: "644387", title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-312x231.jpg"),
    Recipe(recipeId: "635081", title: "Black Beans & Brown Rice With Garlicky Kale", image: "https://img.spoonacular.com/recipes/635081-312x231.jpg"),
    Recipe(recipeId: "644390", title: "Garlicky Roasted Kale", image: "https://img.spoonacular.com/recipes/644390-312x231.jpg")
]

struct RecipeListView: View {
    
//    @StateObject private var favoriteViewModel = FavoriteViewModel()
    @State private var recipes = staticRecipes
    
    var body: some View {
        List {
            ForEach($recipes) { $recipe in
                HStack {
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        AsyncImage(url: URL(string: recipe.image!)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Spacer()
//                    Button(action: {
////                        Task {
////                            await favoriteViewModel.toggleFavoriteStatus(for: recipe)
////                        }
//                    }) {
//                        Image(systemName: favoriteViewModel.isFavorited(recipe: recipe) ? "heart.fill" : "heart")
//                            .foregroundStyle(favoriteViewModel.isFavorited(recipe: recipe) ? .red : .gray)
//                    }
                }
            }
        }
//        .onAppear {
//            Task {
//                await favoriteViewModel.fetchOrCreateFavoriteList()
//                favoriteViewModel.createSubscription()
//            }
//        }
    }
}

//    private func isFavorite(recipe: Recipe) -> Bool {
//        return favoriteViewModel.favoriteRecipes.contains { $0.recipeId == recipe.recipeId }
//    }
//
//    private func toggleFavorite(recipe: Recipe) {
//        if isFavorite(recipe: recipe) {
//            favoriteViewModel.removeFromFavorites(recipe: recipe)
//        } else {
//            favoriteViewModel.addToFavorites(recipe: recipe)
//        }
//    }
    
//    private func fetchFavorites() {
//        Task {
//            do {
//                let response = try await Amplify.API.query(request: .list(Recipe.self, where: Recipe.keys.isFavorite.eq(true))).get()
//                if let fetchedFavorites = response {
//                    favoriteRecipes = fetchedFavorites
//                    update
//                }
//            }
//        }
//    }
//        .onDisappear {
//            favoriteViewModel.cancelSubscription()
//        }
