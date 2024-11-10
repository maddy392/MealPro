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
            if !currentMessage.isCurrentUser {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40, alignment: .center)
                    .clipShape(Circle())
            } else {
                Spacer()
            }
            MessageCell(contentMessage: currentMessage.content,
                        isCurrentUser: currentMessage.isCurrentUser)
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
