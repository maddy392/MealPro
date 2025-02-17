//
//  MessageCell.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/9/24.
//

import SwiftUI

struct MessageCell: View {
//    var contentMessage: String?
//    var recipes: [Recipe] = []
//    var isCurrentUser: Bool
    var chatMessage : ChatMessage
    
    var body: some View {
        let currentUser = chatMessage.isCurrentUser
        
        Group {
            if let contentMessage = chatMessage.content {
                Text(contentMessage)
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom], 5)
                    .foregroundStyle(currentUser ? Color.white : Color.black)
                    .background(currentUser ? Color.blue : Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: currentUser ? .trailing : .leading)
                    .font(currentUser ? .callout : .caption)
            } else if let recipes = chatMessage.recipes, !recipes.isEmpty {
                if recipes.count == 1 {
                    RecipeView(recipe: recipes.first!)
                        .environmentObject(FavoriteViewModel.shared)
//                        .environmentObject(chatViewModel)
                } else {
                    // Use HorizontalRecipeListView when there are multiple recipes.
                    HorizontalRecipeListView(title: "", recipes: recipes)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: currentUser ? .trailing : .leading) // Align based on the user
        .padding(.vertical, 2.5)
    }
}

#Preview("IsCurrentUser") {
    MessageCell(chatMessage: ChatMessage(
        content: "This is a single message cell.",
        isCurrentUser: true
    ))
}

#Preview("NotCurrentUser") {
    MessageCell(chatMessage: ChatMessage(
        content: "This is a single message cell.",
        isCurrentUser: false
    ))
}

#Preview("RecipeMessage") {
    MessageCell(chatMessage: ChatMessage(
        recipe: Recipe(recipeId: 644387, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-312x231.jpg"),
        isCurrentUser: false
    ))
}
