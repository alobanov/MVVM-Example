//
//  ObjectMappable.swift
//  CoinsBank Beta
//
//  Created by Lobanov Aleksey on 24/02/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

protocol MappableConvertibleProtocol {
  func toMappable<T: Mappable>() -> T?
}

extension MappableConvertibleProtocol where Self: ALObjectMappable {
  func toMappable<T: Mappable>() -> T? {
    return Mapper<T>().map(JSON: toJSON())
  }
}

class ALObjectMappable: Object, Mappable {
  public required convenience init?(map _: Map) {
    self.init()
  }

  func map(object _: [String: Any], context _: Realm) throws {
    throw NSError.define(description: "Override map fintion of ObjectMappable")
  }

  // Mappable
  public func mapping(map _: Map) {}
}
