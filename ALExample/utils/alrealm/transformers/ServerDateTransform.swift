//
//  ServerDateTransform.swift
//  CoinsBank
//
//  Created by MOPC on 10.08.16.
//  Copyright © 2016 CoinsBank. All rights reserved.
//

import Foundation
import ObjectMapper

class ServerDateTransform: TransformType {
  typealias Object = Date
  typealias JSON = String

  private var frmttr: DateFormatter

  init(dateFormat: String?, gmt: Bool) {
    frmttr = gmt ? .frmttrGMT : .frmttr

    if let format = dateFormat {
      frmttr.dateFormat = format
    } else {
      frmttr.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    }
  }

  public func transformFromJSON(_ value: Any?) -> Date? {
    if let timeStr = value as? String {
      if let date = frmttr.date(from: timeStr) {
        return date
      }
    }
    return nil
  }

  func transformToJSON(_ value: Date?) -> String? {
    if let date = value {
      let strDate = frmttr.string(from: date as Date)
      return strDate
    }
    return nil
  }
}
