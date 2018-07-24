//
//  LocalNotificationsHelper.swift
//  CoinsBankCruise
//
//  Created by Lobanov Aleksey on 30/05/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RxSwift
import SwiftDate
import UserNotifications

protocol LocalNotificationsHelper {
  func remove(id: String)
  func prepareGranted() -> Observable<Void>
  func createNotifiction(reminder: ReminderModel) -> Single<ReminderModel>
  func allPendingNotofication() -> Observable<[String]>
}

class LocalNotificationsHelperImp: LocalNotificationsHelper {
  enum ErrorType: Int {
    case permissionDenied, wrongDateFormat, wrongOffset
    var error: NSError {
      switch self {
      case .permissionDenied:
        return NSError.define(description: "Permission denied", code: rawValue)
      case .wrongDateFormat:
        return NSError.define(description: "Wrong date format. Cant't serialize it.", code: rawValue)
      case .wrongOffset:
        return NSError.define(description: "Wrong date offset.", code: rawValue)
      }
    }
  }

  private var center = UNUserNotificationCenter.current()

  func prepareGranted() -> Observable<Void> {
    let center = UNUserNotificationCenter.current()
    return Observable<Bool>.create({ observer -> Disposable in
      center.getNotificationSettings { settings in
        switch settings.authorizationStatus {
        case .authorized:
          observer.onNext(false)
          observer.onCompleted()
        case .denied:
          observer.onError(ErrorType.permissionDenied.error)
        case .notDetermined:
          observer.onNext(true)
        }
      }

      return Disposables.create()
    }).flatMap({ [weak self] state -> Observable<Void> in
      state
        ? self?.requestAuthorization() ?? Observable.error(ErrorType.permissionDenied.error)
        : .just(())
    }).observeOn(ALSchedulers.sh.main)
  }

  private func requestAuthorization() -> Observable<Void> {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    let center = UNUserNotificationCenter.current()

    return Observable<Void>.create({ observer -> Disposable in
      center.requestAuthorization(options: options) { granted, error in
        if let err = error {
          observer.onError(err)
        }

        if granted {
          observer.onNext(())
          observer.onCompleted()
        } else {
          observer.onError(ErrorType.permissionDenied.error)
        }
      }

      return Disposables.create()
    })
  }

  func remove(id: String) {
    center.removePendingNotificationRequests(withIdentifiers: [id])
  }

  func allPendingNotofication() -> Observable<[String]> {
    return Observable<[String]>.create { [weak self] observer -> Disposable in
      self?.center.getPendingNotificationRequests(completionHandler: { items in
        observer.onNext(items.map { $0.identifier })
        observer.onCompleted()
      })

      return Disposables.create()
    }
  }

  func pendingNotifications() {
    center.getPendingNotificationRequests { notifications in
      print(notifications.map { $0.identifier })
    }
  }

  func createNotifiction(reminder: ReminderModel) -> Single<ReminderModel> {
    let content = UNMutableNotificationContent()
    content.title = reminder.title
    content.body = reminder.subtitle
    content.sound = UNNotificationSound.default()

    content.userInfo = ["schema": "bccruise://schedule/event?id=\(reminder.identifier)"]

    guard let scheduleDate = reminder.time else {
      return Single.error(ErrorType.wrongDateFormat.error)
    }

    guard let finalDate = (reminder.offset.rawValue.seconds).from(scheduleDate) else {
      return Single.error(ErrorType.wrongOffset.error)
    }

    var cal = Calendar.current
    cal.timeZone = TimeZone(abbreviation: "UTC")!

    var triggerDate = DateComponents()
    triggerDate.year = cal.component(.year, from: finalDate)
    triggerDate.month = cal.component(.month, from: finalDate)
    triggerDate.day = cal.component(.day, from: finalDate)
    triggerDate.hour = cal.component(.hour, from: finalDate)
    triggerDate.minute = cal.component(.minute, from: finalDate)
    triggerDate.second = cal.component(.second, from: finalDate)
    triggerDate.timeZone = TimeZone(abbreviation: "GMT")

    let trigger = UNCalendarNotificationTrigger(
      dateMatching: triggerDate,
      repeats: false
    )

    let identifier = reminder.identifier
    let request = UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger
    )

    return Single<ReminderModel>.create(subscribe: { [weak self] single in
      self?.center.add(request, withCompletionHandler: { error in
        if let err = error {
          single(.error(err))
        } else {
          single(.success(reminder))
        }
      })

      return Disposables.create()
    })
  }
}
