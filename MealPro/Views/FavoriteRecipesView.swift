//
//  FavoriteRecipesView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/12/24.
//

import SwiftUI
import Amplify

struct FavoriteRecipesView: View {
    @EnvironmentObject private var favoriteViewModel: FavoriteViewModel

    var body: some View {
        Group {
            if favoriteViewModel.userFavorites.isEmpty {
                Text("No favorite recipes yet!")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(favoriteViewModel.userFavorites, id: \.id) { favoriteItem in
                        RecipeView(recipe: favoriteItem.recipe)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await favoriteViewModel.fetchUserFavorites()
            }
        }
    }
}
