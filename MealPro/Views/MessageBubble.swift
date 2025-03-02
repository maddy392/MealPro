//
//  MessageBubble.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/19/25.
//

import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // If the message is outgoing, push it to the right.
            if message.direction == .outgoing {
                Spacer()
            }
            
            Group {
                switch message.kind {
                case .text(let text):
                    Text(text)
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 5)
                        .foregroundStyle(Color.white)
                        .background(message.direction == .outgoing ? Color.blue : Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.direction == .outgoing ? .trailing : .leading)
                        .font(message.direction == .outgoing ? .callout : .caption)
                    
                case .recipes(let recipes):
                    if recipes.count == 1 {
                        RecipeView(recipe: recipes.first!)
                            .environmentObject(favoriteViewModel)
                            .environmentObject(chatViewModel)
                    } else {
                        HorizontalRecipeListView(title: "", recipes: recipes)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                    }
                }
            }
            
            // If the message is incoming, push it to the left.
            if message.direction == .incoming {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: message.direction == .outgoing ? .trailing : .leading)
        .padding(.vertical, 2.5)
    }
}

struct SystemMessageView: View {
    let message: SystemMessage

    var body: some View {
        Text(message.displayMessage)
            .font(.caption)
            .foregroundColor(.gray)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    // Sample messages for preview:
    let sampleTextMessage = ChatMessage(text: "Hello! How can I help you today?", direction: .incoming)
    let sampleRecipe = Recipe(recipeId: 945221,
                              title: "Peanut Butter Banana Oat Cookies",
                              image: "https://img.spoonacular.com/recipes/945221-636x393.jpg",
                              vegetarian: true,
                              vegan: true,
                              glutenFree: true,
                              dairyFree: true,
                              cheap: true,
                              veryPopular: true,
                              healthScore: 80,
                              readyInMinutes: 15)
    let sampleRecipeMessage = ChatMessage(recipes: [sampleRecipe, sampleRecipe, sampleRecipe, sampleRecipe], direction: .incoming)
    
    return VStack(spacing: 10) {
        MessageBubble(message: sampleTextMessage)
        MessageBubble(message: sampleRecipeMessage)
    }
    .environmentObject(FavoriteViewModel.shared)
    .environmentObject(ChatViewModel())
}
