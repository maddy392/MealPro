//
//  LargeRecipeImageView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/23/25.
//

import SwiftUI
import Kingfisher

// MARK: - LargeRecipeImageView
struct LargeRecipeImageView: View {
    let recipe: Recipe
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Main Recipe Image
            KFImage(URL(string: recipe.image ?? ""))
                .resizable()
                .roundCorner(
                    radius: .widthFraction(0.1)
                )
                .serialize(as: .PNG)
                .loadDiskFileSynchronously()
                .cacheMemoryOnly()
                .fade(duration: 0.25)
                .frame(height: 200)
            
            // Radial Gradient Overlay for readability
            RadialGradient(
                gradient: Gradient(colors: [Color.black.opacity(1.5), Color.clear]),
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 150
            )
            .cornerRadius(10)
            
            // Title and Dietary Bubbles
            VStack(alignment: .leading, spacing: 0) {
                Text(recipe.title)
                    .font(.headline)
                    .bold()
                    .lineLimit(5)
                    .foregroundColor(.white)
                    .padding(5)
                    .frame(maxWidth: 130, alignment: .leading)
                    .minimumScaleFactor(0.5)
                
                HStack(spacing: 4) {
                    if let glutenFree = recipe.glutenFree, glutenFree {
                        TagBubble(text: "GF", color: .white)
                    }
                    if let vegan = recipe.vegan, vegan {
                        TagBubble(text: "V", color: .white)
                    } else {
                        if let dairyFree = recipe.dairyFree, dairyFree {
                            TagBubble(text: "DF", color: .white)
                        }
                        if let vegetarian = recipe.vegetarian, vegetarian {
                            TagBubble(text: "VG", color: .white)
                        }
                    }
                }
                .padding(.leading, 5)
            }
            .padding(.bottom, 5)
        }
    }
}

#Preview {
    LargeRecipeImageView(recipe: Recipe(
        recipeId: 639606,
        title: "Classic Greek Moussaka",
        image: "https://img.spoonacular.com/recipes/639606-312x231.jpg",
        imageType: "jpg",
        vegetarian: true,
        vegan: false,
        glutenFree: true,
        dairyFree: true,
        veryHealthy: nil,
        cheap: false,
        veryPopular: true,
        sustainable: nil,
        lowFodmap: nil,
        weightWatcherSmartPoints: nil,
        gaps: nil,
        preparationMinutes: nil,
        cookingMinutes: nil,
        aggregateLikes: nil,
        healthScore: 91,
        creditsText: nil,
        sourceName: nil,
        pricePerServing: nil,
        readyInMinutes: 45,
        servings: 4,
        sourceUrl: nil,
        summary: nil,
        cuisines: ["Mediterranean", "Greek"],
        dishTypes: ["lunch", "main course", "dinner"],
        diets: [],
        occasions: [],
        spoonacularSourceUrl: nil,
        spoonacularScore: nil,
        nutrition: nil,
        analyzedInstructions: nil,
        userFavorites: nil,
        createdAt: nil,
        updatedAt: nil
    ))
}
