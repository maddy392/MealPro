//
//  ContentView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authController: AuthController
    
    var body: some View {
        NavigationView {
            TabView {
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
            }
//            .navigationTitle("MealPro") // Optional title
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        Task {
                            await authController.signOut()
                        }
                    }
                }
            }
        }
        .environmentObject(FavoriteViewModel.shared)
    }
}

#Preview {
    ContentView()
}

//public var id: Int { recipeId } // `id` property required by `Identifiable`

