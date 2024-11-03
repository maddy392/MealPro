//
//  RecipeView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/2/24.
//

import SwiftUI

struct RecipeView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: recipe.image!)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } placeholder: {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                
//                HStack {
//                    if recipe.veryHealthy {
//                        Label("Healthy", systemImage: "heart.square.fill")
//                            .font(.caption)
//                            .foregroundStyle(.green)
//                    }
//                    
//                    if recipe.veryPopular {
//                        Label("Popular", systemImage: "star.fill")
//                            .font(.caption)
//                            .foregroundColor(.yellow)
//                    }
//
//                    if recipe.cheap {
//                        Label("Cheap", systemImage: "dollarsign.square.fill")
//                            .font(.caption)
//                            .foregroundColor(.blue)
//                    }
//                }
//                
//                Text("Health Score: \(recipe.healthScore)")
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 5)
    }
}
