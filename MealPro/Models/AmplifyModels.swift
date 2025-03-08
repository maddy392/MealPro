// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "3ccb26a3fa4176ea5eff2534a0919469"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: UserFavorite.self)
    ModelRegistry.register(modelType: User.self)
    ModelRegistry.register(modelType: Recipe.self)
    ModelRegistry.register(modelType: SearchHistory.self)
  }
}