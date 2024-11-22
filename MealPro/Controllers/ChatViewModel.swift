//
//  ChatViewModel.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/8/24.
//
import SwiftUI
import Amplify
import AWSCognitoIdentityProvider
//import AWSClientRuntime
import AWSPluginsCore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var systemMessage: SystemMessage? = nil
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(content: text, isCurrentUser: true)
        messages.append(userMessage)
        
        Task {
            await fetchRecipes(searchText: text)
        }
    }
    
    private func fetchRecipes(searchText: String) async {
        guard let url = URL(string: "https://3nfz5lwaxetbv3zhj5hskjiisq0uzebm.lambda-url.us-east-1.on.aws/api/invokeAgent") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let recipeRequest = ["inputText": searchText, "agentId": "TKAFFO7AR2"]
        do {
            let requestBody = try JSONSerialization.data(withJSONObject: recipeRequest)
            request.httpBody = requestBody
        } catch {
            print("Error encoding request body: \(error)")
            return
        }
        
        DispatchQueue.main.async {
            self.systemMessage = SystemMessage(displayMessage: "Processing...", isFinal: false)
        }
        
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                
                let sessionToken = (credentials as? AWSTemporaryCredentials)?.sessionToken
                
                let signedRequest = try signRequest(
                    request: request,
                    secretSigningKey: credentials.secretAccessKey,
                    accessKeyId: credentials.accessKeyId,
                    sessionToken: sessionToken
                )
                
                let (bytes, _) = try await URLSession.shared.bytes(for: signedRequest)
                
                for try await line in bytes.lines {
//                    print(line)
                    await handleLine(line)
                }
            } else {
                throw URLError(.userAuthenticationRequired)
            }
        } catch let error as AuthError {
            print("Fetch auth session failed with error - \(error)")
            systemMessage = SystemMessage(displayMessage: "Failed to fetch recipes. Please try again.", isFinal: true)
        } catch {
            print("Unexpected error: \(error)")
            systemMessage = SystemMessage(displayMessage: "An unexpected error occurred.", isFinal: true)
        }
    }
    
    @MainActor
    private func handleLine(_ line: String) async {
        if let data = line.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let messageType = json["messageType"] as? String
                    
                    if messageType == "chunk" {
//                        print(json)
                        handleChunkResponse(json)
                    } else if messageType == "trace" {
                        handleTraceMessage(json)
                    }
                }
            } catch {
                print("Failed to parse JSON: \(error)")
            }
        } else {
            print("Received non-JSON line: \(line)")
        }
    }
        
    private func handleChunkResponse(_ json: [String: Any]) {
        if let recipesData = json["recipes"] {
//            print(recipesData)
            do {
                let recipesJsonData = try JSONSerialization.data(withJSONObject: recipesData)
//                print(recipesJsonData)
                let recipes = try JSONDecoder().decode([Recipe].self, from: recipesJsonData)
//                print(recipes)
//                let recipeTitles = recipes.map { $0.title }.joined(separator: "\n")
                var recipeMessage = ChatMessage(recipes: recipes, isCurrentUser: false)
                if let finalChunk = json["text"] as? String {
                    recipeMessage.content = finalChunk
                }
                messages.append(recipeMessage)
            } catch {
                print("Failed to decode recipes: \(error)")
            }
        }
        
//        if let finalChunk = json["text"] as? String {
//            let botMessage = ChatMessage(content: finalChunk, isCurrentUser: false)
//            messages.append(botMessage)
//        }
        systemMessage = nil
    }
        
    private func handleTraceMessage(_ json: [String: Any]) {
        if let displayMsg = json["display_msg"] as? String {
            systemMessage = SystemMessage(displayMessage: displayMsg, isFinal: false)
        }
    }
}
