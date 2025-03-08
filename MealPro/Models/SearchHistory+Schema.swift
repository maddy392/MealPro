// swiftlint:disable all
import Amplify
import Foundation

extension SearchHistory {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case userId
    case query
    case timestamp
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let searchHistory = SearchHistory.keys
    
    model.authRules = [
      rule(allow: .owner, ownerField: "owner", identityClaim: "cognito:username", provider: .userPools, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "SearchHistories"
    model.syncPluralName = "SearchHistories"
    
    model.attributes(
      .index(fields: ["userId", "timestamp"], name: "searchHistoriesByUserIdAndTimestamp"),
      .primaryKey(fields: [searchHistory.id])
    )
    
    model.fields(
      .field(searchHistory.id, is: .required, ofType: .string),
      .field(searchHistory.userId, is: .required, ofType: .string),
      .field(searchHistory.query, is: .required, ofType: .string),
      .field(searchHistory.timestamp, is: .required, ofType: .int),
      .field(searchHistory.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(searchHistory.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
    public class Path: ModelPath<SearchHistory> { }
    
    public static var rootPath: PropertyContainerPath? { Path() }
}

extension SearchHistory: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}
extension ModelPath where ModelType == SearchHistory {
  public var id: FieldPath<String>   {
      string("id") 
    }
  public var userId: FieldPath<String>   {
      string("userId") 
    }
  public var query: FieldPath<String>   {
      string("query") 
    }
  public var timestamp: FieldPath<Int>   {
      int("timestamp") 
    }
  public var createdAt: FieldPath<Temporal.DateTime>   {
      datetime("createdAt") 
    }
  public var updatedAt: FieldPath<Temporal.DateTime>   {
      datetime("updatedAt") 
    }
}