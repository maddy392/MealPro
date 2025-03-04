//
//  WideRecipeView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 3/4/25.
//

import SwiftUI
import Kingfisher

struct WideRecipeView: View {
    let recipe: Recipe
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showDetail = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Recipe Image
            KFImage(URL(string: "https://img.spoonacular.com/recipes/\(recipe.recipeId)-480x360.jpg"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    // Favorite button at top right of image
                    VStack {
                        HStack {
                            Spacer()
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
                        }
                        Spacer()
                    }
                    .padding(4)
                )
            
            // Recipe Info
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true) // Let the view use its intrinsic height
                
                // Dietary Tag Bubbles
                HStack(spacing: 4) {
                    if recipe.glutenFree == true {
                        TagBubble(text: "GF", color: .green)
                    }
                    if recipe.vegan == true {
                        TagBubble(text: "Vegan", color: .blue)
                    } else {
                        if recipe.dairyFree == true {
                            TagBubble(text: "DF", color: .purple)
                        }
                        if recipe.vegetarian == true {
                            TagBubble(text: "VG", color: .orange)
                        }
                    }
                }
                
                // Additional Info (e.g., ready in minutes)
                if let minutes = recipe.readyInMinutes {
                    Text("Ready in \(minutes) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Menu {
                        Button("Find Similar Recipes") {
                            chatViewModel.sendMessage("Give me more recipes like this", recipe: recipe)
                        }
                        Button("Share") {
                            // Implement share action here
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding()
        // Configurable border based on recipe properties:
        .frame(height: 150)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor(for: recipe), lineWidth: 2)
        )
        .padding(.horizontal)
        .contentShape(Rectangle())
        // Tapping the view opens detail (for example, via a sheet)
        .onTapGesture {
            // Replace with your desired navigation behavior.
            print("Tapped recipe: \(recipe.title)")
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            RecipeDetailView(recipe: recipe)
        }
    }
    
    // Helper function to determine border color
    private func borderColor(for recipe: Recipe) -> Color {
        if let vegan = recipe.vegan, vegan {
            return .green
        } else if let vegetarian = recipe.vegetarian, vegetarian {
            return .orange
        } else {
            return .gray
        }
    }
}

// MARK: - TagBubble View
//struct TagBubble: View {
//    let text: String
//    let color: Color
//    
//    var body: some View {
//        Text(text)
//            .font(.system(size: 10, weight: .semibold))
//            .padding(.horizontal, 6)
//            .padding(.vertical, 2)
//            .background(color.opacity(0.2))
//            .foregroundColor(color)
//            .clipShape(Capsule())
//    }
//}

// MARK: - Preview
#Preview {
    // Create a sample recipe for preview
    let sampleRecipe = Recipe(
        recipeId: 776505,
        title: "Garlicky Kale with Roasted Veggies and Tofu",
        image: "https://img.spoonacular.com/recipes/776505-312x231.jpg",
        vegetarian: true,
        vegan: false,
        glutenFree: true,
        dairyFree: true,
        veryHealthy: nil,
        cheap: nil,
        veryPopular: nil,
        sustainable: nil,
        lowFodmap: nil,
        weightWatcherSmartPoints: nil,
        gaps: nil,
        preparationMinutes: nil,
        cookingMinutes: nil,
        aggregateLikes: nil,
        healthScore: 42,
        creditsText: nil,
        sourceName: nil,
        pricePerServing: nil,
        readyInMinutes: 40,
        servings: nil,
        sourceUrl: nil,
        summary: nil,
        cuisines: nil,
        dishTypes: nil,
        diets: nil,
        occasions: nil,
        spoonacularSourceUrl: nil,
        spoonacularScore: nil,
        nutrition: nil,
        analyzedInstructions: nil,
        userFavorites: nil,
        createdAt: nil,
        updatedAt: nil
    )
    
    WideRecipeView(recipe: sampleRecipe)
        .environmentObject(FavoriteViewModel.shared)
        .environmentObject(ChatViewModel())
}
