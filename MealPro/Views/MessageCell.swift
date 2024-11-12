//
//  MessageCell.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/9/24.
//

import SwiftUI

struct MessageCell: View {
    
    var contentMessage: String?
    var recipes: [Recipe] = []
    var isCurrentUser: Bool
    
    var body: some View {
        if isCurrentUser || recipes.isEmpty {
            Text(contentMessage ?? "")
                .padding(10)
                .foregroundStyle(isCurrentUser ? Color.white : Color.black)
                .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            VStack(alignment: .leading, spacing: 10) {
                
                Text("Here are some recipes")
                ForEach(recipes, id: \.recipeId) { recipe in
                    RecipeView(recipe: recipe)
                        .environmentObject(FavoriteViewModel.shared)
                }
            }
            .padding(10)
//            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview("IsCurrentUser") {
    MessageCell(contentMessage: "This is a single message cell.", isCurrentUser: true)
}

#Preview("NotCurrentUser") {
    MessageCell(contentMessage: "This is a single message cell.", isCurrentUser: false)
}

#Preview("RecipeMessage") {
    MessageCell(recipes: [
        Recipe(recipeId: 644387, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-312x231.jpg"),
        Recipe(recipeId: 635081, title: "Black Beans & Brown Rice With Garlicky Kale", image: "https://img.spoonacular.com/recipes/635081-312x231.jpg")
    ], isCurrentUser: false)
}
