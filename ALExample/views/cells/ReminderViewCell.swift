//
//  ReminderViewCell.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 10/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class ReminderViewCell: UITableViewCell, ALCellReloadeble, ALCellTappable {
  var tap: ((Any?) -> Void)?

  private let titleReminderLabel = UILabel()
  private let deleteButton: UIButton = {
    let btn = UIButton(type: UIButtonType.system)
    btn.setTitle("Delete", for: .normal)
    return btn
  }()

  private var reminderId: String!
  private let bag = DisposeBag()

  override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    configureView()
    addSubviews()
    makeConstraints()
  }

  required init(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureView() {
    titleReminderLabel.font = UIFont.systemFont(ofSize: 16)
    titleReminderLabel.textColor = .black
    titleReminderLabel.numberOfLines = 1
    titleReminderLabel.textAlignment = .left

    backgroundColor = UIColor.white

    deleteButton.rx.tap.asDriver().drive(onNext: { [weak self] _ in
      self?.tap?(self?.reminderId ?? 0)
    }).disposed(by: bag)
  }

  private func addSubviews() {
    addSubview(titleReminderLabel)
    addSubview(deleteButton)
  }

  private func makeConstraints() {
    deleteButton.snp.makeConstraints { maker in
      maker.centerY.equalToSuperview()
      maker.right.equalToSuperview().offset(-20)
      maker.height.equalTo(45)
    }

    titleReminderLabel.snp.makeConstraints { maker in
      maker.left.equalToSuperview().offset(15)
      maker.top.equalToSuperview().offset(16)
      maker.right.equalTo(deleteButton.snp.left).offset(-10)
      maker.bottom.equalToSuperview().offset(-16)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }

  func reload(with model: ALCellModel) {
    guard let cellModel = model as? ReminderCellModel else {
      return
    }

    titleReminderLabel.text = cellModel.id
    reminderId = cellModel.id
  }
}
