//
//  ChatView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/8/24.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var text = ""
    @FocusState private var isFocused: Bool
    @Namespace private var animation

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Spacer(minLength: 20)
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message)
                            .matchedGeometryEffect(id: message.id, in: animation)
                            .id(message.id)
//                            .padding(.vertical, verticalPadding(for: message))
                    }
                    // Insert the typing indicator as part of the message list.
                    if let sysMsg = viewModel.systemMessage {
                        TypingIndicatorMessageView(systemMessage: sysMsg)
                            .id("typingIndicator")
                    }
                    // Extra clear space so the last element isn't hidden.
                    Color.clear.frame(height: 20)
                }
                .padding(5)
            }
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                inputField(with: proxy)
            }
            .onChange(of: viewModel.messages) { _, _ in
                scrollToLatest(using: proxy)
            }
            .onChange(of: viewModel.systemMessage) { _, _ in
                scrollToLatest(using: proxy)
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(viewModel)
    }
    
    private func inputField(with proxy: ScrollViewProxy) -> some View {
        HStack(alignment: .bottom) {
            TextField("Enter message...", text: $text, axis: .vertical)
                .padding(.vertical, 8)
                .padding(.horizontal)
                .focused($isFocused)
                .onSubmit { submit() }
                .onChange(of: isFocused) { _, _ in
                    withAnimation {
                        scrollToLatest(using: proxy)
                    }
                }
            
            Button(action: submit) {
                Image(systemName: "arrow.up.circle.fill")
                    .imageScale(.large)
            }
            .tint(.blue)
            .disabled(text.isEmpty)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .padding()
        .background(
            Rectangle()
                .fill(Color(.systemBackground).opacity(0.95))
                .ignoresSafeArea()
        )
    }
    
    private func verticalPadding(for message: ChatMessage) -> CGFloat {
        // Customize vertical spacing per message if needed.
        return 10
    }
    
    private func scrollToLatest(using proxy: ScrollViewProxy) {
        withAnimation {
            if viewModel.systemMessage != nil {
                proxy.scrollTo("typingIndicator", anchor: .bottom)
            } else {
                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
            }
        }
    }
    
    private func submit() {
        guard !text.isEmpty else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        text = ""
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.sendMessage(trimmed)
        }
    }
}
