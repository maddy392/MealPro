//
//  ContentView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    var body: some View {
        NavigationView {
            TabView {
                HomeView() // Add the HomeView as the first tab
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                AllRecipesView()
                    .tabItem {
                        Label("Recipes", systemImage: "frying.pan.fill")
                    }
                ChatView()
                    .tabItem {
                        Label("RecipeAI", systemImage: "apple.intelligence")
                    }
                FavoriteRecipesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                    .badge(favoriteViewModel.favoritesCount)
            }
//            .navigationTitle("MealPro") // Optional title
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: {
//                        Task {
//                            await authController.signOut()
//                        }
//                    }) {
//                        Label("Sign Out", systemImage: "arrow.right.circle.fill")
//                            .foregroundColor(.red)
//                    }
//                }
//            }
        }
        .environmentObject(FavoriteViewModel.shared)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthController()) // Provide AuthController
        .environmentObject(FavoriteViewModel.shared) // Provide FavoriteViewModel
}

//public var id: Int { recipeId } // `id` property required by `Identifiable`

