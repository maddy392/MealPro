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
        HStack(alignment: .top, spacing: 12) {
            // Recipe Image with Favorite Button overlay
            KFImage(URL(string: "https://img.spoonacular.com/recipes/\(recipe.recipeId)-480x360.jpg"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 80)
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
                            .buttonStyle(PlainButtonStyle()) 
                        }
                        Spacer()
                    }
                    .padding(4)
                )
            
            // 2. Recipe Info VStack
            VStack(alignment: .leading, spacing: 6) {
                // Title (allows up to 2 lines, then truncates with ellipsis)
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                
                // Dietary Tag Bubbles
                HStack(spacing: 4) {
                    if recipe.glutenFree == true { TagBubble(text: "GF", color: .green) }
                    if recipe.vegan == true { TagBubble(text: "Vegan", color: .blue) }
                    else {
                        if recipe.dairyFree == true { TagBubble(text: "DF", color: .purple) }
                        if recipe.vegetarian == true { TagBubble(text: "VG", color: .orange) }
                    }
                }
                
                // Additional Info: Ready in minutes
                if let minutes = recipe.readyInMinutes {
                    Text("Ready in \(minutes) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Macronutrient Breakdown Bar
//                if let nutrition = recipe.nutrition, let caloricBreakdown = nutrition.caloricBreakdown {
//                    MacronutrientBreakdownView(breakdown: caloricBreakdown)
//                        .frame(height: 6)
//                }
                
                // create a line with thickness may be 2; that has 3 colors; proportions for carbs, protein and fat.. and that will be given in public struct CalorificBreakdown: Embeddable {
//                var percentProtein: Double?
//                var percentFat: Double?
//                var percentCarbs: Double?
//              }
            }
            .frame(minWidth: 200, maxWidth: .infinity, alignment: .topLeading)
            
            // 3. Vertical Menu Button
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
        .padding(5)
        .frame(maxWidth: .infinity) // Constrain overall cell size
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(borderColor(for: recipe), lineWidth: 0.5)
//        )
//        .shadow(color: Color.black.opacity(0.75), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 5)
        .contentShape(Rectangle())
        .onTapGesture {
            print("Tapped recipe: \(recipe.title)")
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
    
    // Determine border color based on dietary properties
    private func borderColor(for recipe: Recipe) -> Color {
        if let vegan = recipe.vegan, vegan {
            return .green
        } else if let vegetarian = recipe.vegetarian, vegetarian {
            return .orange
        } else {
            return .gray
        }
    }
    
    struct MacronutrientBreakdownView: View {
        let breakdown: CaloricBreakdown

        var body: some View {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Carbs
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * (breakdown.percentCarbs ?? 0) / 100)
                    
                    // Protein
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * (breakdown.percentProtein ?? 0) / 100)
                    
                    // Fat
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * (breakdown.percentFat ?? 0) / 100)
                }
            }
            .frame(height: 6) // Adjust thickness of the bar
            .clipShape(Capsule()) // Smooth rounded edges
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
        nutrition: RecipeNutrition(caloricBreakdown: CaloricBreakdown(percentProtein: 20, percentFat: 60, percentCarbs: 20)),
        analyzedInstructions: nil,
        userFavorites: nil,
        createdAt: nil,
        updatedAt: nil
    )
    
    WideRecipeView(recipe: sampleRecipe)
        .environmentObject(FavoriteViewModel.shared)
        .environmentObject(ChatViewModel())
}
