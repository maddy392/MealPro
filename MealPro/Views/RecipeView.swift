//
//  RecipeView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/2/24.
//

import SwiftUI

struct RecipeView: View {
    let recipe: Recipe
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: "https://img.spoonacular.com/recipes/\(recipe.recipeId)-90x90.jpg")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } placeholder: {
                ProgressView()
                    .frame(width: 90, height: 90)
            }
            
            VStack(alignment: .leading, spacing: 2.5) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack (spacing: 5) {
//                    Button(action: {
//                        Task {
//                            await favoriteViewModel.toggleFavoriteStatus(for: recipe)
//                        }
//                    }) {
//                        Image(systemName: favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? "heart.fill" : "heart")
//                            .foregroundStyle(favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? .red : .gray)
//                    }
//                    .buttonStyle(BorderlessButtonStyle())
                    
                    if let readyInMinutes = recipe.readyInMinutes {
                        HStack(spacing: 2) {
                            Image(systemName: "clock.badge.fill")
                                .symbolRenderingMode(.multicolor)
    //                            .frame(width: 10, height: 10)
                            
                            Text("\(readyInMinutes)m")
                                .font(.caption2)
                        }
                    }
                    
                    if let glutenFree = recipe.glutenFree, glutenFree == true {
                        Image("GF")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20) // Match size to SF Symbols
                    }
                    if let vegan = recipe.vegan, vegan {
                        Text("Vegan")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else if let vegetarian = recipe.vegetarian, vegetarian {
                        Text("Vegetarian")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else if let dairyFree = recipe.dairyFree, dairyFree {
                        Text("Dairy")
                            .font(.caption2)
                            .foregroundStyle(.purple)
                            .strikethrough()
                    }
                }
                
                if let healthScore = recipe.healthScore {
                    Text("Health Score: \(healthScore)")
                        .foregroundStyle(healthScore >= 50 ? .green : .red)
                        .font(.caption)
                }
                
                HStack (spacing: 2) {
                                        
                    Text(favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? "Remove from Favorites:" : "Add to Favorites:")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    
                    Button(action: {
                        Task {
                            await favoriteViewModel.toggleFavoriteStatus(for: recipe)
                        }
                    }) {
                        Image(systemName: favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? "heart.fill" : "heart")
                            .foregroundStyle(favoriteViewModel.isFavorited(recipeId: recipe.recipeId) ? .red : .gray)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Spacer(minLength: 2)
                }
            }
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading) // Restrict width and align to leading
        .contextMenu {
            Button("Find Similar Recipes") {
                chatViewModel.sendMessage("Give me more recipes like this", recipe: recipe)
//                chatViewModel.sendMessage("Recipe ID: \(recipe.recipeId)")
                
            }
        }
    }
}

#Preview {
    RecipeView(recipe: Recipe(recipeId: 644387, title: "Garlicky Kale", image: "https://img.spoonacular.com/recipes/644387-90x90.jpg", vegetarian: true, vegan: true, glutenFree: true, dairyFree: true, cheap: true, veryPopular: true, healthScore: 42, readyInMinutes: 40))
        .environmentObject(FavoriteViewModel.shared)
        .environmentObject(ChatViewModel())
}
