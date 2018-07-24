//
//  RealmMapper.swift
//  CoinsBank Beta
//
//  Created by Lobanov Aleksey on 27/02/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RealmSwift

class ALRlmMapper<BaseType: ALObjectMappable> {
  static func map<T: ALObjectMappable>(type _: T.Type, object: [String: Any], context: Realm) throws -> T {
    let key = T.primaryKey() ?? "Primary key is not defined"

    if let entity = context.object(ofType: T.self, forPrimaryKey: object[key] ?? "") {
      try entity.map(object: object, context: context)
      return entity
    } else {
      let entity = T()
      try entity.map(object: object, context: context)
      return entity
    }
  }

  private var context: Realm

  public init(context: Realm) {
    self.context = context
  }

  public func mapRelationToOne<T: ALObjectMappable>(relation: String, type _: T.Type, object: [String: Any]) throws -> T? {
    let relationKey = relation
    var mapping: T?

    if let relationObj = object[relationKey] as? JSONDictionary {
      mapping = try ALRlmMapper.map(type: T.self, object: relationObj, context: context)
    }

    return mapping
  }

  public func mapRelationToMany<T: ALObjectMappable>(relation: String, type _: T.Type, object: [String: Any]) throws -> [T]? {
    var mapping: [T]?
    let relationKey = relation

    if let relationArr = object[relationKey] as? JSONArrayDictionary {
      let mapper = ALRlmMapper<T>(context: context)
      mapping = try mapper.mapArray(objects: relationArr)
    }

    return mapping
  }

  public func mapSelf(object: [String: Any]) throws -> BaseType {
    let result: BaseType? = try ALRlmMapper.map(type: BaseType.self, object: object, context: context)
    if let result = result {
      return result
    } else {
      throw NSError.define(description: "Error mapping type\(BaseType.self)")
    }
  }

  @discardableResult public func mapArray(objects: [[String: Any]]) throws -> [BaseType] {
    var operations = [BaseType]()
    for obj in objects {
      let operation: BaseType = try ALRlmMapper.map(type: BaseType.self, object: obj, context: context)
      operations.append(operation)
    }

    return operations
  }
}
