//
//  HomeView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/2/25.
//

import SwiftUI
import Amplify

struct HomeView: View {
    @EnvironmentObject var authController: AuthController
    
    // List of cuisines to display
    let cuisines = [
        "Italian", "Mexican", "American", "Asian", "Chinese",
        "Japanese", "Indian", "Mediterranean", "French", "Greek",
        "Spanish", "Thai", "Korean", "Vietnamese", "Latin American",
        "British", "Caribbean", "Cajun", "German", "Irish",
        "African", "European", "Eastern European", "Southern",
        "Middle Eastern", "Nordic", "Jewish"
    ]
    
    // Featured recipes with consistent keys
    private var featuredRecipes: [Recipe] {
        let baseRecipes = [
            Recipe(recipeId: 945221, title: "Watching What I Eat: Peanut Butter Banana Oat Breakfast Cookies with Carob / Chocolate Chips", image: "https://img.spoonacular.com/recipes/945221-636x393.jpg", glutenFree: true),
            Recipe(recipeId: 715449, title: "How to Make OREO Turkeys for Thanksgiving", image: "https://img.spoonacular.com/recipes/715449-636x393.jpg"),
            Recipe(recipeId: 776505, title: "Sausage & Pepperoni Stromboli", image: "https://img.spoonacular.com/recipes/776505-636x393.jpg"),
            Recipe(recipeId: 716410, title: "Cannoli Ice Cream w. Pistachios & Dark Chocolate", image: "https://img.spoonacular.com/recipes/716410-636x393.jpg"),
            Recipe(recipeId: 715467, title: "Turkey Pot Pie", image: "https://img.spoonacular.com/recipes/715467-636x393.jpg")
        ]
        return [baseRecipes.last!] + baseRecipes + [baseRecipes.first!] // Add buffer items
    }

    @State private var currentIndex = 1 // Start at the first actual item
    
    // Dictionary mapping a cuisine to its fetched recipes.
    @State private var recipesByCuisine: [String: [Recipe]] = [:]
    // A set of cuisines that are currently being loaded.
    @State private var loadingCuisines: Set<String> = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Welcome, \(authController.email.split(separator: "@").first ?? "Guest")")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading) // Left-align text
                    
                    Button(action: {
                        Task {
                            await authController.signOut()
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 20) // Adds space from top
                
                // Featured Recipes Section
                VStack(spacing: 20) {
                    TabView(selection: $currentIndex) {
                        ForEach(0..<featuredRecipes.count, id: \.self) { index in
                            ZStack(alignment: .bottomLeading) {
                                LargeRecipeImageView(recipe: featuredRecipes[index])
                            }
                            .tag(index) // Assign tag for TabView
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: 200)
                    .onChange(of: currentIndex) { _, newValue in
                        if newValue == 0 { // If swiped to the first buffer item
                            currentIndex = featuredRecipes.count - 2 // Move to the last actual item
                        } else if newValue == featuredRecipes.count - 1 { // If swiped to the last buffer item
                            currentIndex = 1 // Move to the first actual item
                        }
                    }
                    
                    // Custom Dots
                    HStack(spacing: 8) {
                        ForEach(0..<featuredRecipes.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.blue : Color.gray)
                                .frame(width: 8, height: 8)
                                .opacity((index == 0 || index == featuredRecipes.count - 1) ? 0 : 1) // Hide first and last dots
                        }
                    }
                    .frame(height: 10)
                }
                .padding(.horizontal, 10)
                
                ForEach(cuisines, id: \.self) { cuisine in
                    VStack(alignment: .leading, spacing: 20) {
//                        Text(
                        if let recipes = recipesByCuisine[cuisine] {
                            HorizontalRecipeListView(title: cuisine, recipes: recipes)
                        } else if loadingCuisines.contains(cuisine) {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .frame(height: 150)
                        } else {
                            GeometryReader { geo in
                                Color.clear
                                    .frame(height: 150)
                                    .onAppear {
                                        let minY = geo.frame(in: .global).minY
                                        let screenHeight = UIScreen.main.bounds.height
                                        // Trigger fetch when the section is about to appear.
                                        if minY < screenHeight {
                                            Task {
                                                print("Fetching recipes for cuisine: \(cuisine)")
                                                await fetchRecipes(for: cuisine)
                                            }
                                        }
                                    }
                            }
                            .frame(height: 150)
                        }
                    }
                    
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 5) // Adds left and right padding
        .navigationTitle("Home")
    }
    
    
    private func fetchRecipes(for cuisine: String) async {
        
        DispatchQueue.main.async {
            loadingCuisines.insert(cuisine)
        }
        
        // Shortened GraphQL query: adjust the query string as needed.
        let query = """
        query MyQuery {
          fetchRecipes(cuisine: "\(cuisine)") {
            recipeId
            title
            image
            imageType
            vegetarian
            vegan
            glutenFree
            veryHealthy
            cheap
            veryPopular
            sustainable
            lowFodmap
            weightWatcherSmartPoints
            gaps
            preparationMinutes
            cookingMinutes
            aggregateLikes
            healthScore
            creditsText
            sourceName
            pricePerServing
            readyInMinutes
            servings
            sourceUrl
            summary
            cuisines
            dishTypes
            diets
            occasions
            spoonacularSourceUrl
            spoonacularScore
            nutrition {
              caloricBreakdown {
                percentCarbs
                percentFat
                percentProtein
              }
              ingredients {
                amount
                id
                name
                unit
              }
              nutrients {
                unit
                percentOfDailyNeeds
                name
                amount
              }
              properties {
                amount
                name
                unit
              }
            }
            analyzedInstructions {
              name
              steps {
                number
                step
                equipment {
                  id
                  name
                }
              }
            }
          }
        }
        """
        let request = GraphQLRequest<[Recipe]>(
            document: query,
            variables: [:],
            responseType: [Recipe].self,
            decodePath: "fetchRecipes"
        )
        
        do {
            let response = try await Amplify.API.query(request: request)
            switch response {
            case .success(let fetchedRecipes):
                // Update the dictionary with fetched recipes.
                DispatchQueue.main.async {
                    recipesByCuisine[cuisine] = fetchedRecipes
                    loadingCuisines.remove(cuisine)
                }
            case .failure(let error):
                print("Error fetching recipes for \(cuisine): \(error)")
                DispatchQueue.main.async { loadingCuisines.remove(cuisine) }
            }
        } catch {
            print("Unexpected error fetching recipes for \(cuisine): \(error.localizedDescription)")
            DispatchQueue.main.async { loadingCuisines.remove(cuisine) }
        }
    }
}

// Custom Corner Radius for Gradient
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthController()) // Provide AuthController for preview
        .environmentObject(FavoriteViewModel.shared)
}
