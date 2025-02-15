//
//  HomeView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/2/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authController: AuthController
    
    // Featured recipes with consistent keys
    private var featuredRecipes: [Recipe] {
        let baseRecipes = [
            Recipe(recipeId: 945221, title: "Watching What I Eat: Peanut Butter Banana Oat Breakfast Cookies with Carob / Chocolate Chips", image: "https://img.spoonacular.com/recipes/945221-636x393.jpg"),
            Recipe(recipeId: 715449, title: "How to Make OREO Turkeys for Thanksgiving", image: "https://img.spoonacular.com/recipes/715449-636x393.jpg"),
            Recipe(recipeId: 776505, title: "Sausage & Pepperoni Stromboli", image: "https://img.spoonacular.com/recipes/776505-636x393.jpg"),
            Recipe(recipeId: 716410, title: "Cannoli Ice Cream w. Pistachios & Dark Chocolate", image: "https://img.spoonacular.com/recipes/716410-636x393.jpg"),
            Recipe(recipeId: 715467, title: "Turkey Pot Pie", image: "https://img.spoonacular.com/recipes/715467-636x393.jpg")
        ]
        return [baseRecipes.last!] + baseRecipes + [baseRecipes.first!] // Add buffer items
    }

    @State private var currentIndex = 1 // Start at the first actual item

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
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
                                AsyncImage(url: URL(string: featuredRecipes[index].image!)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipped()
                                        .cornerRadius(10)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                }
                                
                                // Radial Gradient Overlay
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.black.opacity(1.5), Color.clear]),
                                    center: .bottomLeading,
                                    startRadius: 0,
                                    endRadius: 150 // Adjust radius for size of the gradient
                                )
                                
                                // Recipe Title
                                Text(featuredRecipes[index].title)
                                    .font(.subheadline)
                                    .lineLimit(5)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .frame(maxWidth: 130, alignment: .leading)
                                    .minimumScaleFactor(0.5) // Allow the font size to scale down (50% of the base font)
                                
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
                
                // Horizontally Scrollable Recipe Section
                HorizontalRecipeListView(title: "Featured Recipes", recipes: featuredRecipes)
                HorizontalRecipeListView(title: "Trending Recipes", recipes: featuredRecipes)
                HorizontalRecipeListView(title: "Featured Recipes", recipes: featuredRecipes)
                HorizontalRecipeListView(title: "Trending Recipes", recipes: featuredRecipes)
                HorizontalRecipeListView(title: "Featured Recipes", recipes: featuredRecipes)
                HorizontalRecipeListView(title: "Trending Recipes", recipes: featuredRecipes)
                
                Spacer()
            }
        }
        .padding(.horizontal, 5) // Adds left and right padding
        .navigationTitle("Home")
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
