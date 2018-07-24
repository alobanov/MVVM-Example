//
//  MappableDataTransform.swift
//  CoinsBank
//
//  Created by Lobanov Aleksey on 05.12.2017.
//  Copyright © 2017 CoinsBank. All rights reserved.
//

import Foundation
import ObjectMapper

class MappableDataTransform<T: Mappable>: TransformType {
  typealias Object = [T]
  typealias JSON = JSONDictionary?

  init() {}

  public func transformFromJSON(_ value: Any?) -> Object? {
    guard let json = jsonFromAnyValue(value) else {
      return nil
    }

    return json.compactMap { Mapper<T>().map(JSON: $0) }
  }

  func transformToJSON(_: Object?) -> JSON? {
    return nil
  }

  private func jsonFromAnyValue(_ value: Any?) -> JSONArrayDictionary? {
    if let data: Data = value as? Data,
      let json = NSKeyedUnarchiver.unarchiveObject(with: data) as? JSONArrayDictionary {
      return json
    }
    if let json = value as? JSONArrayDictionary {
      return json
    }
    return nil
  }
}
