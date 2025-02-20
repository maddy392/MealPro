//
//  HorizontalRecipeListView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/12/25.
//

// Horizontally Scrollable Recipe Section
import SwiftUI

struct HorizontalRecipeListView: View {
    let title: String
    let recipes: [Recipe]

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .bold()
                .padding(.leading, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 7.5) {
                    ForEach(recipes, id: \.recipeId) { recipe in
                        RecipeView(recipe: recipe)
                    }
                }
                .padding(.horizontal, 0)
//                .contentShape(Rectangle())
//                .simultaneousGesture(DragGesture())
            }
            .frame(height: 150) // Adjust height as needed
        }
    }
}

#Preview {
    HorizontalRecipeListView(title: "Testing", recipes: [
        Recipe(recipeId: 945221, title: "Watching What I Eat: Peanut Butter Banana Oat Breakfast Cookies with Carob / Chocolate Chips", image: "https://img.spoonacular.com/recipes/945221-636x393.jpg"),
        Recipe(recipeId: 715449, title: "How to Make OREO Turkeys for Thanksgiving", image: "https://img.spoonacular.com/recipes/715449-636x393.jpg"),
        Recipe(recipeId: 776505, title: "Sausage & Pepperoni Stromboli", image: "https://img.spoonacular.com/recipes/776505-636x393.jpg"),
        Recipe(recipeId: 716410, title: "Cannoli Ice Cream w. Pistachios & Dark Chocolate", image: "https://img.spoonacular.com/recipes/716410-636x393.jpg"),
        Recipe(recipeId: 715467, title: "Turkey Pot Pie", image: "https://img.spoonacular.com/recipes/715467-636x393.jpg")
    ])
    .environmentObject(FavoriteViewModel.shared)
}
