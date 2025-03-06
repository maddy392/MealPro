//
//  SearchViewModel.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 3/2/25.
//


import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [Recipe] = []
    
    init() {
        searchResults = [
            Recipe(recipeId: 945221, title: "Watching What I Eat: Peanut Butter Banana Oat Breakfast Cookies with Carob / Chocolate Chips", image: "https://img.spoonacular.com/recipes/945221-636x393.jpg"),
            Recipe(recipeId: 715449, title: "How to Make OREO Turkeys for Thanksgiving", image: "https://img.spoonacular.com/recipes/715449-636x393.jpg", vegetarian: true),
            Recipe(recipeId: 776505, title: "Sausage & Pepperoni Stromboli", image: "https://img.spoonacular.com/recipes/776505-636x393.jpg", dairyFree: true),
            Recipe(recipeId: 716410, title: "Cannoli Ice Cream w. Pistachios & Dark Chocolate", image: "https://img.spoonacular.com/recipes/716410-636x393.jpg", vegan: true),
            Recipe(recipeId: 715467, title: "Turkey Pot Pie", image: "https://img.spoonacular.com/recipes/715467-636x393.jpg", glutenFree: true, readyInMinutes: 30)
        ]
    }

    private let baseURL = "https://p4z8il9otrl0ruy8wqxf.us-east-1.aoss.amazonaws.com/_search"

    func searchRecipes() async {
        print("searching for \(searchText)")
        guard !searchText.isEmpty else {
        DispatchQueue.main.async {
            self.searchResults = []
            }
            return
        }
        
        // Clear dummy data before fetching real results
        DispatchQueue.main.async {
            self.searchResults = []
        }

        let query: [String: Any] = [
            "size": 10,
            "_source": ["recipeId", "title", "vegetarian", "vegan", "dairyFree", "glutenFree"],
            "query": [
                "bool": [
                    "must": [
                        "match": [
                            "title": searchText
                        ]
                    ],
                    "filter": [
                        "term": [
                            "chunk_type": "title"
                        ]
                    ]
                ]
            ]
        ]
        
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                let sessionToken = (credentials as? AWSTemporaryCredentials)?.sessionToken

                let url = URL(string: baseURL)!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: query)

                let signedRequest = try signRequest(
                    request: request,
                    secretSigningKey: credentials.secretAccessKey,
                    accessKeyId: credentials.accessKeyId,
                    sessionToken: sessionToken,
                    serviceName: "aoss"
                )

                let (data, _) = try await URLSession.shared.data(for: signedRequest)
                
                // Print the raw JSON response
                if let rawJson = String(data: data, encoding: .utf8) {
                    print("🔹 Raw JSON response:\n\(rawJson)")
                } else {
                    print("⚠️ Unable to convert response data to String.")
                }
                
                if let decodedResponse = try? JSONDecoder().decode(OpenSearchResponse.self, from: data) {
//                    print(decodedResponse)
                    DispatchQueue.main.async {
                        self.searchResults = decodedResponse.hits.hits.map { $0._source }
                    }
                } else {
                    print("❌ Failed to decode response")
                }
            }
        } catch {
            print("❌ OpenSearch request failed: \(error)")
        }
    }
}
// MARK: - 🔹 OpenSearch Response Model
struct OpenSearchResponse: Codable {
    let hits: HitsContainer
}

struct HitsContainer: Codable {
    let hits: [Hit]
}

struct Hit: Codable {
    let _source: Recipe
}
