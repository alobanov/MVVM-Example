//
//  ReminderEventService.swift
//  CoinsBankCruise
//
//  Created by Lobanov Aleksey on 01/06/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import ObjectMapper
import RxCocoa
import RxSwift

protocol ReminderService {
  func obtainReminders() -> Observable<[ReminderModel]>
  func add(obj: JSONDictionary) -> Observable<Void>
  func remove(reminderId: String) -> Observable<Void>
  func checkGranted() -> Observable<Void>
  func removaAllDeliverdReminders()
}

class ReminderServiceImp: ReminderService {
  private let bag = DisposeBag()

  private let rlm: ALRlmProvider
  private let localNotification: LocalNotificationsHelper

  init(
    coredataProvider: ALRlmProvider,
    localNotification: LocalNotificationsHelper
  ) {
    rlm = coredataProvider
    self.localNotification = localNotification
  }

  func obtainReminders() -> Observable<[ReminderModel]> {
    let pred = NSPredicate(value: true)
    guard let reminderModels: [ReminderModel] = rlm.models(type: RemindData.self, predicate: pred, sortField: "identifier", ascending: true) else {
      return Observable.just([])
    }

    return Observable.just(reminderModels)
  }

  func add(obj: JSONDictionary) -> Observable<Void> {
    guard let reminder = Mapper<ReminderModel>().map(JSON: obj) else {
      return .just(())
    }

    return localNotification.createNotifiction(reminder: reminder)
      .asObservable()
      .observeOn(ALSchedulers.sh.main)
      .flatMap({ [weak self] _ -> Observable<Void> in
        guard let sself = self else {
          return .error(NSError.define(description: "qwer"))
        }

        return sself.rlm.mapObject(RemindData.self, json: reminder.toJSON())
      })
  }

  func checkGranted() -> Observable<Void> {
    return localNotification.prepareGranted()
  }

  func removaAllDeliverdReminders() {
    localNotification.allPendingNotofication()
      .flatMap({ [weak self] ids -> Observable<[String]> in
        let pred = NSPredicate(format: "reminderId NOT IN \(ids)")
        guard let reminders: [ReminderModel] = self?.rlm.models(type: RemindData.self, predicate: pred) else {
          return .error(NSError.define(description: "Failed query"))
        }

        return Observable.just(reminders.map { $0.identifier })
      }).flatMap { [weak self] ids -> Observable<Void> in
        let pred = NSPredicate(format: "identifier IN \(ids)")
        try self?.rlm.delete(type: RemindData.self, predicate: pred)
        return .just(())
      }
      .subscribe()
      .disposed(by: bag)
  }

  func remove(reminderId: String) -> Observable<Void> {
    localNotification.remove(id: reminderId)
    let pred = NSPredicate(format: "identifier == '\(reminderId)'")
    try! rlm.delete(type: RemindData.self, predicate: pred)
    return .just(())
  }
}
