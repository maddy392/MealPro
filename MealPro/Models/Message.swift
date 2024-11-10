//
//  Chat.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/8/24.
//

import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isCurrentUser: Bool
}

struct SystemMessage: Identifiable {
    let id = UUID()
    let displayMessage: String
    var isFinal: Bool = false
}

struct DataSource {
    
    static let messages = [
        
        ChatMessage(content: "Hi there!", isCurrentUser: true),
        
        ChatMessage(content: "Hello! How can I assist you today?", isCurrentUser: false),
        ChatMessage(content: "How are you doing?", isCurrentUser: true),
        ChatMessage(content: "I'm just a computer program, so I don't have feelings, but I'm here and ready to help you with any questions or tasks you have. How can I assist you today?", isCurrentUser: false),
        ChatMessage(content: "Tell me a joke.", isCurrentUser: true),
        ChatMessage(content: "Certainly! Here's one for you: Why don't scientists trust atoms? Because they make up everything!", isCurrentUser: false),
        ChatMessage(content: "How far away is the Moon from the Earth?", isCurrentUser: true),
        ChatMessage(content: "The average distance from the Moon to the Earth is about 238,855 miles (384,400 kilometers). This distance can vary slightly because the Moon follows an elliptical orbit around the Earth, but the figure I mentioned is the average distance.", isCurrentUser: false)
    ]
}
