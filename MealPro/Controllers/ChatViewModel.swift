//
//  ChatViewModel.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/8/24.
//
import SwiftUI
import Amplify
import AWSCognitoIdentityProvider
import AWSPluginsCore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var systemMessage: SystemMessage? = nil
    
    func sendMessage(_ text: String, recipe: Recipe? = nil) {
        
        let searchText: String
        let userMessage: ChatMessage
        
        if let recipe = recipe {
            searchText = "Give me more similar recipes to this recipe. Recipe ID: \(recipe.recipeId)"
            userMessage = ChatMessage(recipe: recipe, direction: .outgoing)
            let userMessage2 = ChatMessage(text: "Give me more such recipes plz", direction: .outgoing)
            withAnimation(.easeInOut(duration: 0.2)) {
                messages.append(userMessage)
                messages.append(userMessage2)
            }
//            messages.append(userMessage)
//            messages.append(userMessage2)
        } else {
            searchText = text
            userMessage = ChatMessage(text: searchText, direction: .outgoing)
            withAnimation(.easeInOut(duration: 0.2)) {
                messages.append(userMessage)
            }
        }
        
//        let userMessage = ChatMessage(content: text, isCurrentUser: true)
        
        Task {
            await invokeAgent(searchText: searchText)
        }
    }
    
    private func invokeAgent(searchText: String) async {
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
                    sessionToken: sessionToken,
                    serviceName: "lambda"
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
                        await handleChunkResponse(json)
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
        
    private func handleChunkResponse(_ json: [String: Any]) async {
        if let recipesData = json["recipes"] {
            do {
                let recipesJsonData = try JSONSerialization.data(withJSONObject: recipesData)
                var recipes = try JSONDecoder().decode([Recipe].self, from: recipesJsonData)
                
                // lets sort recipes by health score
                recipes.sort { ($0.healthScore ?? 0) > ($1.healthScore ?? 0) }
                
                let recipeMessage = ChatMessage(recipes: recipes, direction: .incoming)
                DispatchQueue.main.async {
                    self.messages.append(recipeMessage)
                }
            } catch {
                print("Failed to decode recipes: \(error)")
            }
        }
        
        if let finalChunk = json["text"] as? String {
            let botMessage = ChatMessage(text: finalChunk, direction: .incoming)
            DispatchQueue.main.async {
                self.messages.append(botMessage)
            }
        }
        DispatchQueue.main.async {
            self.systemMessage = nil
        }
    }
        
    private func handleTraceMessage(_ json: [String: Any]) {
        if let displayMsg = json["display_msg"] as? String {
            systemMessage = SystemMessage(displayMessage: displayMsg, isFinal: false)
        }
    }
}
