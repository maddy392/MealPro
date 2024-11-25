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
                    LazyVStack {
                        Spacer(minLength: 20)
                        ForEach(viewModel.messages, id: \.id) { message in
                            MessageView(currentMessage: message)
                                .id(message.id)
                        }
                    }
                    .onChange(of: viewModel.messages) { _ in
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
