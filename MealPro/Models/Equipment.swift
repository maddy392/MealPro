// swiftlint:disable all
import Amplify
import Foundation

public struct Equipment: Embeddable {
  var id: Int
  var name: String
  var localizedName: String?
  var image: String?
}