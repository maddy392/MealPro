//
//  TypingIndicatorView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/19/25.
//

import SwiftUI

struct TypingIndicatorView: View {
    let message: String
    @State private var dotScales: [CGFloat] = [0.5, 0.5, 0.5]

    var body: some View {
        HStack(spacing: 6) {
            Text(message)
                .font(.caption)
                .foregroundColor(.gray)
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(dotScales[index])
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: dotScales[index]
                        )
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
        .onAppear {
            for i in 0..<3 {
                dotScales[i] = 1.0
            }
        }
    }
}


