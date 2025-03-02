////
////  MessageView.swift
////  MealPro
////
////  Created by Madhu Babu Adiki on 11/9/24.
////
//
//import SwiftUI
//
//struct MessageView: View {
//    var currentMessage: ChatMessage
//
//    var body: some View {
//        HStack(alignment: .bottom, spacing: 10) {
//            if currentMessage.isCurrentUser {
//                Spacer()
//            }
//
//            MessageCell(chatMessage: currentMessage)
//        }
//        .frame(maxWidth: .infinity, alignment: currentMessage.isCurrentUser ? .trailing : .leading)
//        .padding(7.5)
//    }
//}
//
//#Preview("IsCurrentUser") {
//    MessageView(currentMessage: ChatMessage(content: "Hello World", isCurrentUser: true))
//}
//
//#Preview("NotCurrentUser") {
//    MessageView(currentMessage: ChatMessage(content: "Hello World", isCurrentUser: false))
//}
//
//#Preview("Recipe") {
//    MessageView(currentMessage: ChatMessage(
//        recipe: Recipe(recipeId: 644387, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-312x231.jpg"),
//        isCurrentUser: false
//    ))
//}
