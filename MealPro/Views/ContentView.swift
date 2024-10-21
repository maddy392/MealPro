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
        TabView {
            RecipeListView()
                .tabItem {
                    Label("Recipes", systemImage: "list.dash")
                }
            FavoriteRecipesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
        }
        .toolbar {
            Button("Sign Out") {
                Task {
                    await authController.signOut()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
