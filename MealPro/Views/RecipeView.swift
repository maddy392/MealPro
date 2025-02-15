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
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ZStack(alignment: .topTrailing) {
                // Recipe Image
                AsyncImage(url: URL(string: "https://img.spoonacular.com/recipes/\(recipe.recipeId)-636x393.jpg")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Add to Favorites Button (top trailing)
                Button(action: {
                    Task {
                        await favoriteViewModel.toggleFavoriteStatus(for: recipe)
                    }
                }) {
                    Image(systemName: favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? "heart.fill" : "heart")
                        .foregroundColor(favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? .red : .black)
                        .padding(5)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(2.5) // Align button to the top trailing corner
            }
            .frame(width: 120, height: 120) // Ensure ZStack is constrained to the image's size
            
            // Recipe Title
            Text(recipe.title)
                .font(.caption)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
//                .frame(maxWidth: 120)
                .frame(width: 120, height:34, alignment: .topLeading)
            
            HStack(spacing: 4) {
                if recipe.glutenFree == true {
                    TagBubble(text: "GF", color: .green)
                }
                if recipe.vegan == true {
                    TagBubble(text: "V", color: .blue)
                } else {
                    if recipe.dairyFree == true {
                        TagBubble(text: "DF", color: .purple)
                    }
                    if recipe.vegetarian == true {
                        TagBubble(text: "VG", color: .orange)
                    }
                }
            }
            .frame(maxWidth: 120, alignment: .leading)
        }
//        .frame(width: 120, height: 160) // Ensure the entire view has the same height
        .contentShape(Rectangle())
        .contextMenu {
            Button("Find Similar Recipes") {
                chatViewModel.sendMessage("Give me more recipes like this", recipe: recipe)
            }
        }
    }
}

// 🔹 Custom Bubble View for Dietary Tags
struct TagBubble: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .bold()
//            .padding(.vertical, 1)
            .padding(.horizontal, 6)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

#Preview {
    RecipeView(recipe: Recipe(recipeId: 776505, title: "Garlicky Kale with Roasted Veggies and Tofu", image: "https://img.spoonacular.com/recipes/776505-312x231.jpg", vegetarian: true, vegan: true, glutenFree: true, dairyFree: true, cheap: true, veryPopular: true, healthScore: 42, readyInMinutes: 40))
        .environmentObject(FavoriteViewModel.shared)
        .environmentObject(ChatViewModel())
}
