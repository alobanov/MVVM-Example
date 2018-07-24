//
//  BaseFormItemComposite.swift
//  ALFormBuilder
//
//  Created by Lobanov Aleksey on 26/10/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

/// Base implementation of FormItemCompositeProtocol
/// For creation new model you should use Decorator pattern for
/// extended it
public class TableModelComposite: TableModelCompositeProtocol {
  public var children: [TableModelCompositeProtocol] = []
  public var level: Int = 0
  public var identifier: String = "root"

  public var datasource: [TableModelCompositeProtocol] {
    return children
  }

  public var customData: Any?

  public required init() {}

  public init(identifier: String, level: Int) {
    self.identifier = identifier
    self.level = level
  }

  public func add(_ model: TableModelCompositeProtocol...) {
    children.append(contentsOf: model)
  }

  public func remove(_ model: TableModelCompositeProtocol) {
    if let index = self.children.index(where: { $0 == model }) {
      children.remove(at: index)
    }
  }
}

public func == (lhs: TableModelCompositeProtocol, rhs: TableModelCompositeProtocol) -> Bool {
  return lhs.identifier == rhs.identifier
}
