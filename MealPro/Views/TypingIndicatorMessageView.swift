//
//  TypingIndicatorMessageView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/19/25.
//
import SwiftUI

struct TypingIndicatorMessageView: View {
    let systemMessage: SystemMessage
    
    var body: some View {
        HStack {
            TypingIndicatorView(message: systemMessage.displayMessage)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
            Spacer()
        }
    }
}
