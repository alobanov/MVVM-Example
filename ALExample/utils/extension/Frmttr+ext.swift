//
//  Frmttr+ext.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 10/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation

public extension Formatter {
  static let frmttrGMT: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()

  static let frmttr: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}
