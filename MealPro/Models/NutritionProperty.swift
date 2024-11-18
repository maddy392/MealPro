// swiftlint:disable all
import Amplify
import Foundation

public struct NutritionProperty: Embeddable {
  var name: String
  var amount: Double?
  var unit: String?
}