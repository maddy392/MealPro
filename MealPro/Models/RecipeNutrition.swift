// swiftlint:disable all
import Amplify
import Foundation

public struct RecipeNutrition: Embeddable {
  var caloricBreakdown: CaloricBreakdown?
  var nutrients: [Nutrient?]?
  var properties: [NutritionProperty?]?
  var ingredients: [Ingredient?]?
}