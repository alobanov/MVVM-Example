//
//  Table+ext.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 09/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import UIKit

protocol CellIdentifiable {
  static var cellIdentifier: String { get }
}

extension CellIdentifiable where Self: UITableViewCell {
  static var cellIdentifier: String {
    return String(describing: self)
  }
}

extension UITableViewCell: CellIdentifiable {}

public extension UITableView {
  typealias RegisterClass = (anyClass: AnyClass?, id: String)

  func dequeueReusableTableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath, andtype: T.Type) -> T {
    guard let cell = self.dequeueReusableCell(withIdentifier: andtype.cellIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier: \(T.cellIdentifier)")
    }

    return cell
  }

  func setupEstimatedRowHeight(height: CGFloat? = nil) {
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = height ?? 60.0
  }

  func setupEstimatedFooterHeight(height: CGFloat? = nil) {
    sectionFooterHeight = UITableViewAutomaticDimension
    estimatedSectionFooterHeight = height ?? 40.0
  }

  func setupEstimatedHeaderHeight(height: CGFloat? = nil) {
    sectionHeaderHeight = UITableViewAutomaticDimension
    estimatedSectionHeaderHeight = height ?? 40.0
  }

  func registerCell(by identifier: String, bundle: Bundle? = nil) {
    register(
      UINib(nibName: identifier, bundle: bundle),
      forCellReuseIdentifier: identifier
    )
  }

  func registerCells(by identifiers: [String], bundle: Bundle? = nil) {
    for identifier in identifiers {
      register(
        UINib(nibName: identifier, bundle: bundle),
        forCellReuseIdentifier: identifier
      )
    }
  }

  func registerClass(anyClass: AnyClass?, identifier: String) {
    register(anyClass, forCellReuseIdentifier: identifier)
  }

  func registerClasses(anyClasses: [RegisterClass]) {
    for item in anyClasses {
      registerClass(anyClass: item.anyClass, identifier: item.id)
    }
  }
}
