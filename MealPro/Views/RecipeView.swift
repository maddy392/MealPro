//
//  RecipeView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/2/24.
//

import SwiftUI
import Kingfisher

struct RecipeView: View {
//    (string: "https://img.spoonacular.com/recipes/\(recipe.recipeId)-480x360.jpg")
    let recipe: Recipe
    let size: CGFloat
    
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showDetail = false  // Controls modal presentation
    
    // ✅ Default size to 100 if not provided
    init(recipe: Recipe, size: CGFloat = 100) {
        self.recipe = recipe
        self.size = size
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ZStack(alignment: .topTrailing) {
                // Recipe Image
                KFImage(URL(string: "https://img.spoonacular.com/recipes/\(recipe.recipeId)-480x360.jpg"))
                    .resizable()
                    .roundCorner(
                        radius: .widthFraction(0.1)
                    )
                    .serialize(as: .PNG)
                    .loadDiskFileSynchronously()
                    .cacheMemoryOnly()
                    .fade(duration: 0.25)
                    .frame(width: size, height: size)
            
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
            .frame(width: size, height: size) // Ensure ZStack is constrained to the image's size
            
            // Recipe Title
            Text(recipe.title)
                .font(.caption)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
//                .frame(maxWidth: 120)
                .frame(width: size, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true) // Let the view use its intrinsic height
            
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
            .frame(maxWidth: 100, alignment: .leading)
        }
//        .frame(width: 120, height: 160) // Ensure the entire view has the same height
        .contentShape(Rectangle())
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            RecipeDetailView(recipe: recipe)
        }
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
            .font(.system(size: 7, weight: .semibold))
            .bold()
//            .padding(.vertical, 1)
            .padding(.horizontal, 6)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

// MARK: - 🔹 Preview with Different Sizes
#Preview {
    VStack {
        RecipeView(recipe: Recipe(recipeId: 776505, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/776505-312x231.jpg", vegetarian: true, vegan: true, glutenFree: true, dairyFree: true, cheap: true, veryPopular: true, healthScore: 42, readyInMinutes: 40), size: 100)
        
        RecipeView(recipe: Recipe(recipeId: 776506, title: "Avocado Toast", image: "https://img.spoonacular.com/recipes/776506-312x231.jpg", vegetarian: true, vegan: true, glutenFree: false, dairyFree: false, cheap: true, veryPopular: true, healthScore: 50, readyInMinutes: 10), size: 120)
        
        RecipeView(recipe: Recipe(recipeId: 776506, title: "Quinoa Salad", image: "https://img.spoonacular.com/recipes/776506-312x231.jpg", vegetarian: true, vegan: true, glutenFree: true, dairyFree: true, cheap: false, veryPopular: true, healthScore: 80, readyInMinutes: 20), size: 200)
    }
    .environmentObject(FavoriteViewModel.shared)
    .environmentObject(ChatViewModel())
}
