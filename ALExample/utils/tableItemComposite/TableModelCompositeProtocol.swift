//
//  FormItemCompositeProtocol.swift
//  FormBuilder
//
//  Created by Lobanov Aleksey on 09/11/2017.
//  Copyright © 2017 Lobanov Aleksey. All rights reserved.
//

import Foundation

/// Common `FormItem` protocol which should implement all of tree items
public protocol TableModelCompositeProtocol {

  // MARK: - Property

  // Unic identifier for each model
  var identifier: String { get }
  // Nested level of tree structure
  var level: Int { get }
  // children nodes
  var children: [TableModelCompositeProtocol] { get }
  // Retrieve only leaves of all tree structure
  var datasource: [TableModelCompositeProtocol] { get }
  // custom data
  var customData: Any? { get set }

  // MARK: - Methods

  // Add child item
  func add(_ model: TableModelCompositeProtocol...)
  // Add child from array
  func add(_ items: [TableModelCompositeProtocol])
  // Remove child item
  func remove(_ model: TableModelCompositeProtocol)
  // reamove all child items
  func removeAll()
  // get item by identifier
  func item(by identifier: String) -> TableModelCompositeProtocol?
}

// MARK: - Extension

/// Default implementation of common methods
public extension TableModelCompositeProtocol {
  func item(by identifier: String) -> TableModelCompositeProtocol? {
    return children.filter { $0.identifier == identifier }.first
  }

  public func add(_ items: [TableModelCompositeProtocol]) {
    for item in items {
      add(item)
    }
  }

  public func add(_: TableModelCompositeProtocol...) {
    print("Implement this method if you want to add new child")
  }

  public func remove(_: TableModelCompositeProtocol) {
    print("Implement this method if you want to remove child")
  }

  public func removeAll() {
    for item in children {
      remove(item)
    }
  }
}
