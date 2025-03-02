////
////  RecipeDetailView.swift
////  MealPro
////
////  Created by Madhu Babu Adiki on 2/22/25.
////
//
import SwiftUI
//
//// MARK: - RecipeImageView
//struct RecipeImageView: View {
//    let recipe: Recipe
//
//    var body: some View {
//        ZStack(alignment: .bottomLeading) {
//            // Main Recipe Image
//            AsyncImage(url: URL(string: recipe.image ?? "")) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .frame(height: 200)
//                    .clipped()
//                    .cornerRadius(10)
//            } placeholder: {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.3))
//                    .frame(height: 200)
//                    .cornerRadius(10)
//            }
//            
//            // Radial Gradient Overlay for readability
//            RadialGradient(
//                gradient: Gradient(colors: [Color.black.opacity(1.5), Color.clear]),
//                center: .bottomLeading,
//                startRadius: 0,
//                endRadius: 150
//            )
//            .cornerRadius(10)
//            
//            // Title and Dietary Bubbles
//            VStack(alignment: .leading, spacing: 0) {
//                Text(recipe.title)
//                    .font(.headline)
//                    .bold()
//                    .lineLimit(5)
//                    .foregroundColor(.white)
//                    .padding(5)
//                    .frame(maxWidth: 130, alignment: .leading)
//                    .minimumScaleFactor(0.5)
//                
//                HStack(spacing: 4) {
//                    if let glutenFree = recipe.glutenFree, glutenFree {
//                        TagBubble(text: "GF", color: .white)
//                    }
//                    if let vegan = recipe.vegan, vegan {
//                        TagBubble(text: "V", color: .white)
//                    } else {
//                        if let dairyFree = recipe.dairyFree, dairyFree {
//                            TagBubble(text: "DF", color: .white)
//                        }
//                        if let vegetarian = recipe.vegetarian, vegetarian {
//                            TagBubble(text: "VG", color: .white)
//                        }
//                    }
//                }
//                .padding(.leading, 5)
//            }
//            .padding(.bottom, 5)
//        }
//    }
//}
//
// MARK: - RecipeDetailView
struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) var dismiss  // Enables modal dismissal

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    
//                     Use the extracted RecipeImageView.
                    LargeRecipeImageView(recipe: recipe)
                        .padding(.horizontal)
                    
                    // MARK: - Ingredients List
                    if let nutrition = recipe.nutrition,
                       let rawIngredients = nutrition.ingredients {
                        let ingredients = rawIngredients.compactMap { $0 }
                        if !ingredients.isEmpty {
                            IngredientsView(ingredients: ingredients)
                        }
                    }
                    
                    // MARK: - Instructions List
                    if let rawInstructions = recipe.analyzedInstructions {
                        let instructions = rawInstructions.compactMap { $0 }
                        if !instructions.isEmpty {
                            InstructionsView(instructions: instructions)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Recipe Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample dummy nutrition data for preview.
        let sampleCaloricBreakdown = CaloricBreakdown(percentProtein: 20.0, percentFat: 30.0, percentCarbs: 50.0)
        let sampleNutrients = [
            Nutrient(name: "Calories", amount: 847, unit: "kcal", percentOfDailyNeeds: 42),
            Nutrient(name: "Fat", amount: 52.4, unit: "g", percentOfDailyNeeds: 80),
            Nutrient(name: "Protein", amount: 42.5, unit: "g", percentOfDailyNeeds: 85)
        ]
        let sampleNutrition = RecipeNutrition(caloricBreakdown: sampleCaloricBreakdown, nutrients: sampleNutrients, ingredients: [
            Ingredient(id: 1, name: "Eggs", amount: 2, unit: "pcs", localizedName: nil, image: nil),
            Ingredient(id: 2, name: "Milk", amount: 200, unit: "ml", localizedName: nil, image: nil)
        ])
        
        let sampleInstructions = AnalyzedInstruction(name: "", steps: [
            InstructionStep(number: 1, step: "Preheat the oven to 180°C.", ingredients: nil, equipment: nil),
            InstructionStep(number: 2, step: "Mix all ingredients in a bowl.", ingredients: nil, equipment: nil),
            InstructionStep(number: 3, step: "Bake for 45 minutes.", ingredients: nil, equipment: nil)
        ])
        
        let sampleRecipe = Recipe(
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
            nutrition: sampleNutrition,
            analyzedInstructions: [sampleInstructions],
            userFavorites: nil,
            createdAt: nil,
            updatedAt: nil
        )
        
        return RecipeDetailView(recipe: sampleRecipe)
    }
}
#endif
