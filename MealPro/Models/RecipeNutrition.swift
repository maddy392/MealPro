// swiftlint:disable all
import Amplify
import Foundation

public struct RecipeNutrition: Embeddable {
  var calorificBreakdown: CalorificBreakdown?
  var nutrients: [Nutrient?]?
  var properties: [NutritionProperty?]?
  var ingredients: [Ingredient?]?
}