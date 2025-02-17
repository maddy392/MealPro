//
//  ChatView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/8/24.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var userInput = ""

    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        Spacer(minLength: 20)
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, message in
                            MessageView(currentMessage: message)
                                .padding(.vertical, verticalPadding(for: index))
                                .id(message.id)
                        }
                    }
                    .onChange(of: viewModel.messages) {
                        withAnimation {
                            scrollViewProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onAppear {
                        withAnimation {
                            scrollViewProxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                if let systemMessage = viewModel.systemMessage {
                    Text(systemMessage.displayMessage)
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding(.bottom, 8)
                }
                
                HStack {
                    TextField("Enter message...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 44)
                        .onSubmit {
                            sendUserMessage()
                        }
                    
                    Button(action: sendUserMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundStyle(.blue)
                    }
                    .disabled(userInput.isEmpty)
                }
                .padding()
            }
        }
        .padding(.top, 16)
        .navigationBarTitle("Chat", displayMode: .inline)
        .environmentObject(viewModel)
    }
    
    /// Compute vertical padding for a message at a given index based on the sender of the previous message.
    private func verticalPadding(for index: Int) -> CGFloat {
        // For the first message, use a larger gap.
        guard index > 0 else { return 20 }
        let current = viewModel.messages[index]
        let previous = viewModel.messages[index - 1]
        // If consecutive messages are from different senders, use a small gap.
        // If previous is from current user and current is from bot: small gap
        if previous.isCurrentUser && !current.isCurrentUser {
            return -5
        }
        // If previous is from bot and current is from current user: larger gap
        else if !previous.isCurrentUser && current.isCurrentUser {
            return 10
        }
        // If both are from the same sender, use standard gap
        else {
            return -5
        }
    }

    private func sendUserMessage() {
        let message = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        viewModel.sendMessage(message)
        userInput = ""
    }
}

#Preview {
    NavigationView {
        ChatView()
    }
}
