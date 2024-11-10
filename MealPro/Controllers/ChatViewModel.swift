//
//  ChatViewModel.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/8/24.
//
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var systemMessage: SystemMessage? = nil
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(content: text, isCurrentUser: true)
        messages.append(userMessage)
        
        streamResponse(for: text)
    }
    
    private func streamResponse(for userText: String) {
        self.systemMessage = SystemMessage(displayMessage: "Processing...", isFinal: false)
        
        // Simulate streaming API with a series of messages
        let events = [
            SystemMessage(displayMessage: "Hang Tight, we are working on it!"),
            SystemMessage(displayMessage: "Agent is thinking!"),
            SystemMessage(displayMessage: "Agent is calling on its resources!"),
            SystemMessage(displayMessage: "Almost there!"),
            SystemMessage(displayMessage: "Here are your recipe recommendations!", isFinal: true)
        ]
        
        for (index, event) in events.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1)) {
                if event.isFinal {
                    self.messages.append(ChatMessage(content: event.displayMessage, isCurrentUser: false))
                    self.systemMessage = nil
                } else {
                    self.systemMessage = event
                }
            }
        }
    }
}
