//
//  GridView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 3/2/25.
//

import SwiftUI

struct GridView: View {
    var recipes: [Recipe]  // Your list of Recipe objects
    let rowSpacing: CGFloat
    
    init(recipes: [Recipe], rowSpacing: CGFloat = 20) {
        self.recipes = recipes
        self.rowSpacing = rowSpacing
    }


    private var columns: [GridItem] {
            [GridItem(.flexible(), spacing: rowSpacing),
             GridItem(.flexible(), spacing: rowSpacing),
             GridItem(.flexible(), spacing: rowSpacing)]
        }
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: rowSpacing) {
                    ForEach(recipes) { recipe in
                        RecipeView(recipe: recipe, size: 120)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
        }
}

// MARK: - 🔹 Preview
#Preview {
    GridView(recipes: [
        Recipe(recipeId: 945221, title: "Watching What I Eat: Peanut Butter Banana Oat Breakfast Cookies with Carob / Chocolate Chips", image: "https://img.spoonacular.com/recipes/945221-636x393.jpg", dairyFree: true),
        Recipe(recipeId: 715449, title: "How to Make OREO Turkeys for Thanksgiving", image: "https://img.spoonacular.com/recipes/715449-636x393.jpg"),
        Recipe(recipeId: 776505, title: "Sausage & Pepperoni Stromboli", image: "https://img.spoonacular.com/recipes/776505-636x393.jpg"),
        Recipe(recipeId: 716410, title: "Cannoli Ice Cream w. Pistachios & Dark Chocolate", image: "https://img.spoonacular.com/recipes/716410-636x393.jpg"),
        Recipe(recipeId: 715467, title: "Turkey Pot Pie", image: "https://img.spoonacular.com/recipes/715467-636x393.jpg",
               vegan: true)
    ], rowSpacing: 20)
    .environmentObject(FavoriteViewModel.shared)
}
