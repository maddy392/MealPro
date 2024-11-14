// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "df1f343cb5d21467e484ca3a5affe22e"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: UserFavorite.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Recipe.self)
  }
}