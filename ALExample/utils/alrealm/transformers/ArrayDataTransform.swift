//
//  ArrayDataTransform.swift
//  CoinsBank
//
//  Created by Lobanov Aleksey on 09.12.2017.
//  Copyright © 2017 Pavel Pryamikov. All rights reserved.
//

import ObjectMapper

class ArrayDataTransform<T>: TransformType {
  typealias Object = [T]
  typealias JSON = [T]

  func transformFromJSON(_ value: Any?) -> [T]? {
    if let data: Data = value as? Data,
      let array = NSKeyedUnarchiver.unarchiveObject(with: data) as? [T] {
      return array
    }

    return nil
  }

  func transformToJSON(_: [T]?) -> [T]? {
    return nil
  }
}
