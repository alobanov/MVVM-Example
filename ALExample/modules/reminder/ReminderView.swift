//
//  ReminderView.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 09/07/2018.
//  Copyright (c) 2018 Lobanov Aleksey. All rights reserved.
//

import SnapKit
import UIKit

class ReminderView: UIView {
  let tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.separatorStyle = .none
    return tableView
  }()

  var addButton: UIBarButtonItem = {
    UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: nil)
  }()

  let reminderEmptyContainer = UIView()
  private let reminderEmptyLabel = UILabel()

  var addReminderButton: UIButton = {
    let btn = UIButton(type: UIButtonType.contactAdd)
    btn.setTitle("Add reminder", for: .normal)
    btn.titleEdgeInsets = UIEdgeInsets(top: 1.0, left: 7.0, bottom: 0.0, right: 20.0)
    btn.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 20.0)
    btn.semanticContentAttribute = .forceRightToLeft
    return btn
  }()

  override init(frame: CGRect = CGRect.zero) {
    super.init(frame: frame)

    configureView()
    addSubviews()
    makeConstraints()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configureView() {
    backgroundColor = .white

    tableView.setupEstimatedRowHeight()
    tableView.registerClasses(anyClasses: [
      ALCell.system.cellRegisterClass,
      Cells.reminder.cellRegisterClass
    ])

    reminderEmptyLabel.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
    reminderEmptyLabel.textColor = .black
    reminderEmptyLabel.numberOfLines = 0
    reminderEmptyLabel.text = "You can add remainders, just push the button below"
    reminderEmptyLabel.textAlignment = .center

    reminderEmptyContainer.alpha = 0
  }

  func addSubviews() {
    addSubview(tableView)
    addSubview(reminderEmptyContainer)

    reminderEmptyContainer.addSubview(reminderEmptyLabel)
    reminderEmptyContainer.addSubview(addReminderButton)
  }

  func makeConstraints() {
    reminderEmptyContainer.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.height.greaterThanOrEqualTo(10).priority(.low)
    }

    reminderEmptyLabel.snp.makeConstraints { make in
      make.left.right.top.equalToSuperview()
    }

    addReminderButton.snp.makeConstraints { make in
      make.top.equalTo(reminderEmptyLabel.snp.bottom).offset(25)
      make.size.equalTo(CGSize(width: 200, height: 40))
      make.centerX.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    tableView.snp.makeConstraints { make in
      make.top.right.left.bottom.equalToSuperview()
    }
  }
}
