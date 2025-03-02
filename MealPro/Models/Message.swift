//
//  Chat.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/8/24.
//

import SwiftUI

public struct ChatMessage: Identifiable, Equatable {
    public var id = UUID()
    public var date = Date()
    public let direction: Direction
    public let kind: Kind
    
    public enum Kind: Equatable {
        case text(String)
        case recipes([Recipe])
        
        public static func == (lhs: Kind, rhs: Kind) -> Bool {
            switch (lhs, rhs) {
            case (.text(let lText), .text(let rText)):
                return lText == rText
            case (.recipes(let lRecipes), .recipes(let rRecipes)):
                // Compare based on recipeId (order doesn't matter)
                let lIds = Set(lRecipes.map { $0.recipeId })
                let rIds = Set(rRecipes.map { $0.recipeId })
                return lIds == rIds
            default:
                return false
            }
        }
    }
    
    public enum Direction: Equatable {
        case outgoing, incoming
    }
    
    // Convenience initializers
    public init(text: String, direction: Direction) {
        self.kind = .text(text)
        self.direction = direction
    }
    
    public init(recipe: Recipe, direction: Direction) {
        self.kind = .recipes([recipe])
        self.direction = direction
    }
    
    public init(recipes: [Recipe], direction: Direction) {
        self.kind = .recipes(recipes)
        self.direction = direction
    }
}

struct SystemMessage: Identifiable, Equatable {
    let id = UUID()
    let displayMessage: String
    var isFinal: Bool = false
}

//struct DataSource {
//    
//    static let messages = [
//        
//        ChatMessage(content: "Hi there!", isCurrentUser: true),
//        
//        ChatMessage(content: "Hello! How can I assist you today?", isCurrentUser: false),
//        ChatMessage(content: "How are you doing?", isCurrentUser: true),
//        ChatMessage(content: "I'm just a computer program, so I don't have feelings, but I'm here and ready to help you with any questions or tasks you have. How can I assist you today?", isCurrentUser: false),
//        ChatMessage(content: "Tell me a joke.", isCurrentUser: true),
//        ChatMessage(content: "Certainly! Here's one for you: Why don't scientists trust atoms? Because they make up everything!", isCurrentUser: false),
//        ChatMessage(content: "How far away is the Moon from the Earth?", isCurrentUser: true),
//        ChatMessage(content: "The average distance from the Moon to the Earth is about 238,855 miles (384,400 kilometers). This distance can vary slightly because the Moon follows an elliptical orbit around the Earth, but the figure I mentioned is the average distance.", isCurrentUser: false)
//    ]
//}
