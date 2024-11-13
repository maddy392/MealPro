//
//  RecipeView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/2/24.
//

import SwiftUI

struct RecipeView: View {
    let recipe: Recipe
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "https://img.spoonacular.com/recipes/\(recipe.recipeId)-90x90.jpg")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } placeholder: {
                ProgressView()
                    .frame(width: 90, height: 90)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Button(action: {
                        Task {
                            await favoriteViewModel.toggleFavoriteStatus(for: recipe)
                        }
                    }) {
                        Image(systemName: favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? "heart.fill" : "heart")
                            .foregroundStyle(favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? .red : .gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
    }
}

#Preview {
    RecipeView(recipe: Recipe(recipeId: 644387, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-90x90.jpg"))
        .environmentObject(FavoriteViewModel.shared)
}
