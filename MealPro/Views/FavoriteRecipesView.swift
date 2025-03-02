//
//  FavoriteRecipesView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 10/12/24.
//

import SwiftUI
import Amplify
import AWSCognitoIdentityProvider
import AWSPluginsCore

struct FavoriteRecipesView: View {
    @EnvironmentObject private var favoriteViewModel: FavoriteViewModel

    var body: some View {
        Group {
            if favoriteViewModel.userFavorites.isEmpty {
                Text("No favorite recipes yet!")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(favoriteViewModel.userFavorites, id: \.id) { favoriteItem in
                        RecipeView(recipe: favoriteItem.recipe)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await favoriteViewModel.fetchUserFavorites()
//                await fetchRecipesFromOpenSearch()
            }
        }
    }
    
//    // MARK: - Fetch Recipes from OpenSearch
//    private func fetchRecipesFromOpenSearch() async {
//        guard let url = URL(string: "https://p4z8il9otrl0ruy8wqxf.us-east-1.aoss.amazonaws.com/_search") else {
//            print("Invalid OpenSearch URL")
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // OpenSearch query to match recipes by title
//        let query: [String: Any] = [
//            "size": 10,
//            "_source": ["recipe_id", "title", "vegetarian", "vegan", "dairyFree", "glutenFree"],
//            "query": [
//                "multi_match": [
//                    "query": "salt",
//                    "fields": ["title^2", "ingredients"]
//                ]
//            ]
//        ]
//        
//        do {
//            let requestBody = try JSONSerialization.data(withJSONObject: query)
//            request.httpBody = requestBody
//        } catch {
//            print("Error encoding OpenSearch request body: \(error)")
//            return
//        }
//
//        do {
//            let session = try await Amplify.Auth.fetchAuthSession()
//            if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
//                let credentials = try awsCredentialsProvider.getAWSCredentials().get()
//                
//                print("🔑 Access Key ID: \(credentials.accessKeyId)")
//                print("🔑 Secret Access Key: \(credentials.secretAccessKey)")
//                
//                let sessionToken = (credentials as? AWSTemporaryCredentials)?.sessionToken
//                print("🔑 Session Token: \(sessionToken ?? "None")")
//                
//                let signedRequest = try signRequest(
//                    request: request,
//                    secretSigningKey: credentials.secretAccessKey,
//                    accessKeyId: credentials.accessKeyId,
//                    sessionToken: sessionToken
//                )
//
//                let (data, response) = try await URLSession.shared.data(for: signedRequest)
//
//                guard let httpResponse = response as? HTTPURLResponse else {
//                    print("Unexpected response: \(response)")
//                    return
//                }
//
//                if httpResponse.statusCode == 200 {
//                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data) {
//                        print("🔍 OpenSearch Response JSON:\n\(jsonResponse)")
//                    } else {
//                        print("⚠️ Failed to parse OpenSearch JSON response")
//                    }
//                } else {
//                    print("❌ OpenSearch request failed with status code: \(httpResponse.statusCode)")
//                    if let responseText = String(data: data, encoding: .utf8) {
//                        print("Response body: \(responseText)")
//                    }
//                }
//                
//            } else {
//                throw URLError(.userAuthenticationRequired)
//            }
//        } catch let error as AuthError {
//            print("Fetch auth session failed with error - \(error)")
//        } catch {
//            print("Unexpected error: \(error)")
//        }
//    }
}
