//
//  UniversalDatasourceModel.swift
//  Pulse
//
//  Created by Aleksey Lobanov on 09.10.16.
//  Copyright © 2016 Aleksey Lobanov All rights reserved.
//

import RxDataSources

enum ALCell: ALCellProtocol {
  case system
  var type: UITableViewCell.Type {
    return UITableViewCell.self
  }
}

public protocol ALCellProtocol {
  var type: UITableViewCell.Type { get }
}

public protocol ALCellModel: class {
  var diffIdentifier: String? { get }
  var cellType: ALCellProtocol { get }
  var identifier: String { get }
  func strictReload() -> Bool
}

public protocol ALCellReloadeble {
  func reload(with model: ALCellModel)
}

public protocol ALCellImageCancelable {
  func cancelImageLoading()
}

public protocol ALCellTappable {
  var tap: ((_ data: Any?) -> Void)? { get set }
}

public struct ALSection {
  public var items: [ALSectionItem]
  public var identifier: String
  public var model: TableModelCompositeProtocol & ALSectionCellModel

  init(model: TableModelCompositeProtocol & ALSectionCellModel) {
    items = model.items
    identifier = model.identifier
    self.model = model
  }
}

public struct ALSectionItem {
  public var model: ALCellModel

  public init(model: ALCellModel) {
    self.model = model
  }
}

extension ALCellProtocol {
  var cellIdentifier: String {
    return type.cellIdentifier
  }

  var cellRegisterClass: UITableView.RegisterClass {
    return (type.classForCoder(), cellIdentifier)
  }
}

extension ALCellModel {
  func strictReload() -> Bool {
    return false
  }
}

extension ALSection: AnimatableSectionModelType {
  public typealias Item = ALSectionItem
  public typealias Identity = String

  public var identity: String {
    return identifier
  }

  public init(original: ALSection, items: [Item]) {
    self = original
    self.items = items
  }
}

extension ALSectionItem: IdentifiableType, Equatable {
  public typealias Identity = String

  public var identity: String {
    return model.identifier
  }

  var diff: String {
    return model.diffIdentifier ?? ""
  }

  public func strictReload() -> Bool {
    return model.strictReload()
  }
}

// equatable, this is needed to detect changes
public func == (lhs: ALSectionItem, rhs: ALSectionItem) -> Bool {
  return lhs.identity == rhs.identity && !lhs.strictReload() && lhs.diff == rhs.diff
}

extension TableModelCompositeProtocol {
  var items: [ALSectionItem] {
    if let section = self as? TableModelCompositeProtocol & ALSectionCellModel {
      return section.children.flatMap { $0.items }
    }

    if let model = self as? ALCellModel {
      return [ALSectionItem(model: model)]
    }

    return []
  }
}

public typealias ALCellCustomAction = ((_ data: Any?, _ item: ALSection.Item) -> Void)
public class ALRxDSHelper {
  public static func configureCell(action: ALCellCustomAction? = nil) ->
    RxTableViewSectionedAnimatedDataSource<ALSection>.ConfigureCell {
    return { _, tv, ip, i in
      let cell = tv.dequeueReusableTableCell(forIndexPath: ip, andtype: i.model.cellType.type)

      if let c = cell as? ALCellReloadeble {
        c.reload(with: i.model)
      }

      if let c = cell as? ALCellImageCancelable {
        c.cancelImageLoading()
      }

      if var c = cell as? ALCellTappable {
        c.tap = { data in
          action?(data, i)
        }
      }

      cell.selectionStyle = UITableViewCellSelectionStyle.none
      return cell
    }
  }
}
