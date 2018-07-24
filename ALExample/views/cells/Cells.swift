//
//  Cells.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 10/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import UIKit

public enum Cells: Int, ALCellProtocol {
  case reminder

  public var type: UITableViewCell.Type {
    switch self {
    case .reminder:
      return ReminderViewCell.self
    }
  }
}
