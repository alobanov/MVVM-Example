//
//  RowSettings.swift
//  ALFormBuilder
//
//  Created by Lobanov Aleksey on 29/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation
import UIKit.UITableViewCell

public struct ALHelp {
  public struct Reload {
    public var isStrictReload: Bool = false
    public var isEditingNow: Bool = false

    public mutating func needReloadModel() {
      isStrictReload = true
    }

    public mutating func changeisEditingNow(_ state: Bool) {
      isEditingNow = state
    }

    public mutating func strictReload() -> Bool {
      var needReload = false
      if isStrictReload != needReload {
        isStrictReload = false
        if !isEditingNow {
          needReload = true
        }
      }

      return needReload
    }
  }
}
