//
//  ReminderCellModel.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 10/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation

class ReminderCellModel: ALItemCellModel {
  let t: String
  let ts: String
  let id: String

  override var diffIdentifier: String? {
    return t
  }

  init(model: ReminderModel) {
    t = model.title
    ts = model.subtitle
    id = model.identifier

    super.init(identifier: model.identifier)
    cellType = Cells.reminder
  }
}
