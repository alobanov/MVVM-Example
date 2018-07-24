//
//  ReminderViewModel.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 09/07/2018.
//  Copyright (c) 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol ReminderViewOutput {
  func configure(input: ReminderViewModel.Input) -> ReminderViewModel.Output
}

class ReminderViewModel: RxViewModelType, RxViewModelModuleType, ReminderViewOutput {

  // MARK: In/Out struct

  struct InputDependencies {
    let service: ReminderService
  }

  struct Input {
    let addReminder: Observable<ReminderModel.Offset>
    let removeReminder: Observable<String>
  }

  struct Output {
    let title: Observable<String>
    let state: Observable<ModelState>
    let dataSource: Observable<[ALSection]>
    let availableOffsets: Observable<[ReminderModel.Offset]>
  }

  // MARK: Dependencies

  private let dp: InputDependencies
  private let moduleInputData: ModuleInputData

  // MARK: Properties

  private let bag = DisposeBag()
  private let modelState: RxViewModelStateProtocol = RxViewModelState()
  private let dataSource = BehaviorSubject<[ALSection]>(value: [])
  private let availableOffsets = BehaviorSubject<[ReminderModel.Offset]>(value: [])

  // MARK: Observables

  private let title = Observable.just("Reminder")

  // MARK: - initializer

  init(dependencies: InputDependencies, moduleInputData: ModuleInputData) {
    dp = dependencies
    self.moduleInputData = moduleInputData
  }

  // MARK: - ReminderViewOutput

  func configure(input: Input) -> Output {
    // Configure input
    input.addReminder.subscribe(onNext: { [weak self] offset in
      self?.add(offset: offset)
    }).disposed(by: bag)

    input.removeReminder.subscribe(onNext: { [weak self] id in
      self?.remove(id: id)
    }).disposed(by: bag)

    availableOffsets.onNext(ReminderModel.Offset.all)
    prepareDs()

    // Configure output
    return Output(
      title: title.asObservable(),
      state: modelState.state.asObservable(),
      dataSource: dataSource.asObservable(),
      availableOffsets: availableOffsets.asObservable()
    )
  }

  // MARK: - Module configuration

  func configureModule(input _: ModuleInput?) -> ModuleOutput {
    // Configure input signals

    // Configure module output
    return ModuleOutput()
  }

  // MARK: - Additional

  func add(offset: ReminderModel.Offset) {
    let obj: JSONDictionary = [
      "offset": offset.rawValue,
      "title": "Example",
      "subtitle": "Example subtitle",
      "identifier": UUID().uuidString,
      "time": Date().toISO()
    ]

    dp.service.checkGranted().flatMap({ [weak self] _ -> Observable<Void> in
      self?.dp.service.add(obj: obj) ?? .just(())
    }).subscribe(onNext: { [weak self] _ in
      self?.prepareDs()
    }, onError: { [weak self] err in
      self?.modelState.show(error: err as NSError)
    }).disposed(by: bag)
  }

  func remove(id: String) {
    dp.service.remove(reminderId: id)
      .subscribe(onNext: { [weak self] _ in
        self?.prepareDs()
      }, onError: { [weak self] err in
        self?.modelState.show(error: err as NSError)
      }).disposed(by: bag)
  }

  func prepareDs() {
    dp.service.obtainReminders()
      .map { $0.map(ReminderCellModel.init) }
      .map { models -> [ALSection] in
        let container = ALSectionCellModel(identifier: "default")
        container.add(models)
        return [ALSection(model: container)]
      }
      .do(onError: { [weak self] err in
        self?.modelState.show(error: err as NSError)
      })
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] sections in
        self?.dataSource.onNext(sections)
      }).disposed(by: bag)
  }

  deinit {
    print("-- ReminderViewModel dead")
  }
}
