//
//  AllRecipesView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/2/24.
//

import SwiftUI
import Amplify

struct AllRecipesView: View {
    @State private var selectedCuisine: String? = ""
    @State private var selectedDiet: String? = ""
    @State private var recipes: [Recipe] = []
    @State private var isLoading: Bool = false
    @State private var selectedRecipe: Recipe? = nil
    @EnvironmentObject private var favoriteViewModel: FavoriteViewModel
    
    let cuisines = [
        "All",
        "Italian",
        "Mexican",
        "American",
        "Asian",
        "Chinese",
        "Japanese",
        "Indian",
        "Mediterranean",
        "French",
        "Greek",
        "Spanish",
        "Thai",
        "Korean",
        "Vietnamese",
        "Latin American",
        "British",
        "Caribbean",
        "Cajun",
        "German",
        "Irish",
        "African",
        "European",
        "Eastern European",
        "Southern",
        "Middle Eastern",
        "Nordic",
        "Jewish"
    ]

    let diets = [
        "All",
        "Vegetarian",
        "Vegan",
        "Gluten Free",
        "Ketogenic",
        "Paleo",
        "Whole30",
        "Pescetarian",
        "Lacto-Vegetarian",
        "Ovo-Vegetarian",
        "Primal"
    ]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -10) {
                    ForEach(cuisines, id: \.self) { cuisine in
                        VStack(spacing: -10) {
                            Text(cuisine)
                                .padding()
                                .foregroundColor(self.selectedCuisine == cuisine ? .black : .gray)
                                .fontWeight(self.selectedCuisine == cuisine ? .bold : .regular)
                                .cornerRadius(8)
                                .onTapGesture {
                                    if cuisine == "All" {
                                        self.selectedCuisine = ""
                                    } else {
                                        self.selectedCuisine = cuisine
                                    }
                                    print(cuisine)
                                    Task {
                                        await self.fetchRecipes()
                                    }
                                }
                            if selectedCuisine == cuisine || (cuisine == "All" && selectedCuisine == "") {
                                Rectangle()
                                    .fill(.red)
                                    .frame(height: 2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -10) {
                    ForEach(diets, id: \.self) { diet in
                        VStack(spacing: -10) {
                            Text(diet)
                                .padding()
                                .foregroundColor(self.selectedDiet == diet ? .black : .gray)
                                .fontWeight(self.selectedDiet == diet ? .bold : .regular)
                                .cornerRadius(8)
                                .onTapGesture {
                                    if diet == "All" {
                                        self.selectedDiet = ""
                                    } else {
                                        self.selectedDiet = diet
                                    }
                                    print(diet)
                                    Task {
                                        await self.fetchRecipes()
                                    }
                                }
                            if selectedDiet == diet || (diet == "All" && selectedDiet == "")     {
                                Rectangle()
                                    .fill(.red)
                                    .frame(height: 2)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 0)
            }
            
            if isLoading {
                ProgressView("Loading Recipes...")
//                    .padding()
            }
            
            List(recipes) { recipe in
                RecipeView(recipe: recipe)
                .onTapGesture {
                    self.selectedRecipe = recipe
                }
            }
            .padding(.bottom, 5)
            
            // Footnote
            Text("All data is sourced from Spoonacular API")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
        .onAppear {
            Task {
                await fetchRecipes()
            }
        }
//        .sheet(item: $selectedRecipe) { recipe in
//            RecipeDetailView(recipe: recipe)
//        }
    }
    
    func fetchRecipes() async {
        isLoading = true
        defer { isLoading = false }

        print("Fetching Recipes for cuisine: \(String(describing: selectedCuisine)) and diet \(String(describing: selectedDiet))")
        
        let operationName = "fetchRecipes"
        let query = """
            query FetchRecipes($cuisine: String!, $diet: String!) {
                \(operationName)(cuisine: $cuisine, diet: $diet) {
                    recipeId
                    title
                    image
                    imageType
                }
            }
        """
        
        let request = GraphQLRequest<[Recipe]>(
            document: query,
            variables: [
                "cuisine": selectedCuisine ?? "",
                "diet": selectedDiet ?? ""
            ],
            responseType: [Recipe].self,
            decodePath: operationName
        )
        
        do {
            let response = try await Amplify.API.query(request: request)
            switch response {
            case .success(let recipes):
                DispatchQueue.main.async {
                    self.recipes = recipes
                }
            case .failure(let error):
                print("Failed to fetch recipes: \(error)")
            }
        } catch {
            print("Unexpected error fetching recipes: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AllRecipesView()
}
