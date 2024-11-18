// swiftlint:disable all
import Amplify
import Foundation

public struct Ingredient: Embeddable {
  var id: Int
  var name: String
  var amount: Double?
  var unit: String?
  var localizedName: String?
  var image: String?
}