//
//  RxRegularCellModel.swift
//  CoinsBank Beta
//
//  Created by Lobanov Aleksey on 22/02/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation

public class ALItemCellModel: TableModelCompositeProtocol, ALCellModel {
  public var cellType: ALCellProtocol = ALCell.system

  public var identifier: String {
    return decoratedComposite.identifier
  }

  public var diffIdentifier: String? {
    return "\(identifier)"
  }

  public var children: [TableModelCompositeProtocol] {
    return []
  }

  public var datasource: [TableModelCompositeProtocol] {
    return [self]
  }

  public var level: Int {
    return decoratedComposite.level
  }

  public var customData: Any? {
    get { return decoratedComposite.customData }
    set(new) { decoratedComposite.customData = new }
  }

  public var reload = ALHelp.Reload()

  public var decoratedComposite: TableModelCompositeProtocol

  init(identifier: String) {
    decoratedComposite = TableModelComposite(identifier: identifier, level: 1)
  }

  public func strictReload() -> Bool {
    return reload.strictReload()
  }
}
