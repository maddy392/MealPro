//
//  IngredientsView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/23/25.
//
import SwiftUI

struct IngredientsView: View {
    let ingredients: [Ingredient]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Ingredients")
                .font(.headline)
                .padding(.horizontal)
            ForEach(ingredients, id: \.id) { ingredient in
                // Format amount: if the value is a whole number, display as integer; otherwise, show the decimal.
                let displayAmount: String = {
                    guard let amount = ingredient.amount else { return "0" }
                    if amount.truncatingRemainder(dividingBy: 1) == 0 {
                        return String(Int(amount))
                    } else {
                        return String(amount)
                    }
                }()
                
                let unitDisplay = {
                    let unit = ingredient.unit ?? ""
                    return unit.isEmpty ? "" : " " + unit
                }()
                Text("\(ingredient.name) (\(displayAmount)\(unitDisplay))")
                    .font(.caption)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    IngredientsView(ingredients: [
        Ingredient(id: 100220444, name: "basmati Rice", amount: 1.0, unit: "servings"),
        Ingredient(id: 100200626, name: "pods cardamom", amount: 0.38, unit: "")
    ])
}
