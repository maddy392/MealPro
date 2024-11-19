//
//  MessageView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/9/24.
//

import SwiftUI

struct MessageView: View {
    
    var currentMessage: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if currentMessage.isCurrentUser {
                Spacer()
            }
            if let recipes = currentMessage.recipes, !recipes.isEmpty {
                MessageCell(contentMessage: currentMessage.content, recipes: recipes, isCurrentUser: currentMessage.isCurrentUser)
            } else {
                MessageCell(contentMessage: currentMessage.content, isCurrentUser: currentMessage.isCurrentUser)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

#Preview("IsCurrentUser") {
    MessageView(currentMessage: ChatMessage(content: "Hello World", isCurrentUser: true))
}

#Preview("NotCurrentUser") {
    MessageView(currentMessage: ChatMessage(content: "Hello World", isCurrentUser: false))
}

#Preview("Recipes") {
    MessageView(currentMessage: ChatMessage(recipes: [
        Recipe(recipeId: 644387, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-312x231.jpg"),
        Recipe(recipeId: 635081, title: "Black Beans & Brown Rice With Garlicky Kale", image: "https://img.spoonacular.com/recipes/635081-312x231.jpg")
    ], isCurrentUser: false))
}
