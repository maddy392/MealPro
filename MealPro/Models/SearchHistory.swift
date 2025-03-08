// swiftlint:disable all
import Amplify
import Foundation

public struct SearchHistory: Model, Identifiable {
  public let id: String
  public var userId: String
  public var query: String
  public var timestamp: Int
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      userId: String,
      query: String,
      timestamp: Int) {
    self.init(id: id,
      userId: userId,
      query: query,
      timestamp: timestamp,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      userId: String,
      query: String,
      timestamp: Int,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.userId = userId
      self.query = query
      self.timestamp = timestamp
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}
