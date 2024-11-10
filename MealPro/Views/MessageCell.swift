//
//  MessageCell.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/9/24.
//

import SwiftUI

struct MessageCell: View {
    
    var contentMessage: String
    var isCurrentUser: Bool
    
    var body: some View {
        Text(contentMessage)
            .padding(10)
            .foregroundStyle(isCurrentUser ? Color.white : Color.black)
            .background(isCurrentUser ? Color.blue : Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview("IsCurrentUser") {
    MessageCell(contentMessage: "This is a single message cell.", isCurrentUser: true)
}

#Preview("NotCurrentUser") {
    MessageCell(contentMessage: "This is a single message cell.", isCurrentUser: false)
}
