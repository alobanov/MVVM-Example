//
//  ReminderViewController.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 09/07/2018.
//  Copyright (c) 2018 Lobanov Aleksey. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class ReminderViewController: UIViewController {

  // MARK: - Properties

  // Dependencies
  var viewModel: ReminderViewOutput?

  // Public
  var bag = DisposeBag()

  // Private
  private let didTapAddReminder = PublishSubject<ReminderModel.Offset>()
  private let didRemoveReminder = PublishSubject<String>()
  private var availableOffsets: [ReminderModel.Offset] = []

  // IBOutlet & UI
  lazy var customView = self.view as? ReminderView

  // MARK: - View lifecycle

  override func loadView() {
    let view = ReminderView()
    self.view = view
  }

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()

    do {
      try configureRx()
    } catch let err {
      print(err)
    }
  }

  // MARK: - Configuration

  private func configureRx() throws {
    guard let model = viewModel, let content = customView else {
      throw RxViewModelState.viewModelError()
    }

    // in/out
    let input = ReminderViewModel.Input(
      addReminder: didTapAddReminder.asObservable(),
      removeReminder: didRemoveReminder.asObservable()
    )
    let output = model.configure(input: input)

    // bindings
    output.title.bind(to: rx.title).disposed(by: bag)

    // datasource
    let dataSource = RxTableViewSectionedAnimatedDataSource<ALSection>(
      configureCell: ALRxDSHelper.configureCell(action: { [weak self] data, _ in
        self?.didRemoveReminder.onNext(data as! String)
      })
    )

    dataSource.animationConfiguration = AnimationConfiguration(
      insertAnimation: .fade,
      reloadAnimation: .fade,
      deleteAnimation: .fade
    )

    output.dataSource
      .do(onNext: { [weak self] sections in
        self?.showEmptyReminderInfo(state: (sections.first?.items.isEmpty ?? true))
      })
      .bind(to: content.tableView.rx.items(dataSource: dataSource))
      .disposed(by: bag)

    output.availableOffsets
      .map { !$0.isEmpty }
      .bind(to: content.addButton.rx.isEnabled)
      .disposed(by: bag)

    output.state.subscribe(onNext: { [weak self] state in
      switch state {
      case let .error(err): self?.handle(err)
      default: break
      }
    }).disposed(by: bag)

    Driver.merge(
      content.addButton.rx.tap.asDriver(),
      content.addReminderButton.rx.tap.asDriver()
    )
    .withLatestFrom(output.availableOffsets.asDriver(onErrorJustReturn: []))
    .drive(onNext: { [weak self] offsets in
      self?.addReminderDialog(offsets: offsets)
    })
    .disposed(by: bag)
  }

  private func configureUI() {
    guard let content = self.customView else { return }
    navigationItem.rightBarButtonItem = content.addButton
  }

  // MARK: - Additional

  func handle(_ err: NSError?) {
    guard let err = err else { return }
    
    switch err.code {
    case LocalNotificationsHelperImp.ErrorType.permissionDenied.rawValue:
      showPermissionDeniedDialog()
    default:
      showError(err)
    }
  }
  
  private func showEmptyReminderInfo(state: Bool) {
    guard let content = self.customView else { return }
    UIView.animate(withDuration: 0.3) {
      content.reminderEmptyContainer.alpha = state ? 1 : 0
    }
  }

  private func addReminderDialog(offsets: [ReminderModel.Offset]) {
    let alert = UIAlertController(
      title: "Available reminders",
      message: "Choose offset:",
      preferredStyle: .actionSheet
    )
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    for offset in offsets {
      alert.addAction(UIAlertAction(title: offset.descrTitle, style: .default, handler: { [weak self] _ in
        self?.didTapAddReminder.onNext(offset)
      }))
    }

    present(alert, animated: true, completion: nil)
  }

  private func showError(_ error: NSError) {
    let alert = UIAlertController(
      title: "Something goes wrong 😲",
      message: error.localizedDescription,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: true, completion: nil)
  }

  private func showPermissionDeniedDialog() {
    let alert = UIAlertController(
      title: "Local notifications is denied",
      message: "You can move to application settings and allow receiving local notifications.",
      preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
      let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)!
      UIApplication.shared.open(settingsUrl)
    }))

    present(alert, animated: true, completion: nil)
  }

  deinit {
    print("ReminderViewController deinit")
  }
}
