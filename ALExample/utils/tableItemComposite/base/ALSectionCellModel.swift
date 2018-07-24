//
//  RxRegularSectionModel.swift
//  CoinsBank Beta
//
//  Created by Lobanov Aleksey on 12/03/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import UIKit

public class ALSectionCellModel: TableModelCompositeProtocol {

  // MARK: - SectionFormCompositeOutput

  var header: String?
  var footer: String?

  // MARK: - Provate propery

  private var decoratedComposite: TableModelCompositeProtocol

  // MARK: - FormItemCompositeProtocol properties

  public var identifier: String {
    return decoratedComposite.identifier
  }

  public var children: [TableModelCompositeProtocol] {
    return decoratedComposite.children
  }

  public var datasource: [TableModelCompositeProtocol] {
    return decoratedComposite.children.flatMap { $0.datasource }
  }

  public var customData: Any? {
    get { return decoratedComposite.customData }
    set(new) { decoratedComposite.customData = new }
  }

  public var level: Int = 0

  init(identifier: String, header: String? = nil, footer: String? = nil) {
    let composite = TableModelComposite(identifier: identifier, level: level)
    decoratedComposite = composite
    self.header = header
    self.footer = footer
  }

  public func add(_ model: TableModelCompositeProtocol...) {
    for item in model {
      if item.level != 0 {
        decoratedComposite.add(item)
      } else {
        print("You can`t add section in other section")
      }
    }
  }

  public func heightHeader(byWidth: CGFloat, heightOffset: CGFloat, fontSize: CGFloat) -> CGFloat {
    var text: String = ""
    if let headerText = header, !headerText.isEmpty {
      text = headerText
    } else {
      return 0
    }

    return height(string: text, width: byWidth, heightOffset: heightOffset, fontSize: fontSize)
  }

  public func heightFooter(byWidth: CGFloat, heightOffset: CGFloat, fontSize: CGFloat) -> CGFloat {
    if footer?.isEmpty ?? false {
      return 0
    }

    return height(string: footer ?? "", width: byWidth, heightOffset: heightOffset, fontSize: fontSize)
  }

  private func height(string: String, width: CGFloat, heightOffset: CGFloat, fontSize: CGFloat) -> CGFloat {
    let attr = AZTextFrameAttributes(string: string, width: width, font: UIFont.systemFont(ofSize: fontSize))
    return AZTextFrame(attributes: attr).height + heightOffset
  }

  public func remove(_ model: TableModelCompositeProtocol) {
    decoratedComposite.remove(model)
  }

  public func removeAll() {
    for item in children {
      remove(item)
    }
  }
}
