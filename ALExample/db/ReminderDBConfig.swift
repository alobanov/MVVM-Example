//
//  ReminderDBConfig.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 10/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RealmSwift

let dbname = "test.realm"

class ReminderDBConfig: ALBaseRlmConfigurator, ALRlmConfigurator {
  private var existingRealm: Realm?

  func define(realmName _: String, encryptionKey: Data) {
    databaseName = generateFilename()
    self.encryptionKey = encryptionKey
  }

  func protectInstance() -> Realm? {
    do {
      return try instance()
    } catch _ {
      return nil
    }
  }

  func instance() throws -> Realm {
    if databaseName.isEmpty {
      throw NSError.define(description: "Need define database name")
    }

    if let realm = existingRealm {
      return realm
    }

    clearCache()
    let realmFileURL = fullPath(by: databaseName)
    var realmConfiguration = Realm.Configuration()
    realmConfiguration.fileURL = realmFileURL
    realmConfiguration.schemaVersion = 1
    realmConfiguration.deleteRealmIfMigrationNeeded = true
    realmConfiguration.objectTypes = [
      RemindData.self
    ]

    do {
      existingRealm = try Realm(configuration: realmConfiguration)
      return existingRealm!
    } catch let error as NSError {
      if error.code == 2 && error.userInfo["Underlying"] as? String == "Realm file decryption failed" {
        throw error
      } else {
        throw error
      }
    }
  }

  deinit {
    print("UserRealmConfiguratorImp: \(databaseName) dead")
  }
}
