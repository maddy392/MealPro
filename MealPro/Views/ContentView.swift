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
        .toolbar {
            Button("Sign Out") {
                Task {
                    await authController.signOut()
                }
            }
        }
        .environmentObject(FavoriteViewModel.shared)
    }
}

#Preview {
    ContentView()
}
