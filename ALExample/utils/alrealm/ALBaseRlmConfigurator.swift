//
//  BaseRealmConfigurator.swift
//  CoinsBank Beta
//
//  Created by Lobanov Aleksey on 24/02/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RealmSwift

protocol ALRlmConfigurator {
  @discardableResult func instance() throws -> Realm
  func protectInstance() -> Realm?
  func define(realmName: String, encryptionKey: Data)

  func fullPath(by name: String) -> URL
  func isRealmFileExist(name: String) -> Bool
  func generateFilename() -> String

  func deleteAllRealm() -> NSError?
  func deleteRealm(exceptFileName: String) -> NSError?
}

class ALBaseRlmConfigurator {
  internal var realmsDirectoryURL: URL
  internal var realmFileURL: URL!
  internal var databaseName: String = ""
  internal var encryptionKey: Data = Data()

  convenience init(name: String, key: Data) {
    self.init()
    databaseName = name
    encryptionKey = key
  }

  convenience init(name: String) {
    self.init()
    databaseName = name
  }

  init() {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    realmsDirectoryURL = URL(fileURLWithPath: path, isDirectory: true)
      .appendingPathComponent("realms", isDirectory: true)
    try? FileManager.default.createDirectory(
      atPath: realmsDirectoryURL.path,
      withIntermediateDirectories: true,
      attributes: nil
    )
  }

  func fullPath(by name: String) -> URL {
    var url = realmsDirectoryURL.appendingPathComponent(name)

    do {
      var resourceValue = URLResourceValues()
      resourceValue.isExcludedFromBackup = true
      try (url as NSURL).setResourceValue(URLFileProtection.complete, forKey: .fileProtectionKey)
      try url.setResourceValues(resourceValue)

      return url
    } catch _ {
      return url
    }
  }

  func isRealmFileExist(name: String) -> Bool {
    return FileManager.default.fileExists(atPath: name)
  }

  func generateFilename() -> String {
    let realmFileName = UUID().uuidString + ".realm"
    return realmFileName
  }

  func deleteAllRealm() -> NSError? {
    return deleteRealm(exceptFileName: "")
  }

  func deleteRealm(exceptFileName: String) -> NSError? {
    // deterimne current realm file
    let realmFileURL = fullPath(by: exceptFileName)

    // delete all other realms in directory
    let keepFileNames = [
      realmFileURL.lastPathComponent,
      realmFileURL.lastPathComponent + ".lock",
      realmFileURL.lastPathComponent + ".note",
      realmFileURL.lastPathComponent + ".management"
    ]

    let filesEnumerator = FileManager.default.enumerator(at: realmsDirectoryURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants, errorHandler: nil)!
    for fileObj in filesEnumerator {
      let fileURL = fileObj as! URL
      if !keepFileNames.contains(fileURL.lastPathComponent) {
        do {
          try FileManager.default.removeItem(at: fileURL)
        } catch {
          return NSError.define(description: "Can't delete realm files")
        }
      }
    }

    return nil
  }

  func clearCache() {
    let deleteFileNames = [
      ".lock",
      ".note",
      ".management"
    ]

    do {
      if #available(iOS 10.0, *) {
        let tmpDirectory: URL = FileManager.default.temporaryDirectory

        let filesEnumerator = FileManager.default.enumerator(at: tmpDirectory, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants, errorHandler: nil)!
        for fileObj in filesEnumerator {
          let fileURL = fileObj as! URL
          let p = deleteFileNames.filter { fileURL.lastPathComponent.contains($0) }

          if !p.isEmpty {
            try FileManager.default.removeItem(at: fileURL)
          }
        }
      } else {
        let files = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())

        for fileObj in files {
          let path = String(format: "%@%@", NSTemporaryDirectory(), fileObj)
          let p = deleteFileNames.filter { path.contains($0) }

          if !p.isEmpty {
            try FileManager.default.removeItem(atPath: path)
          }
        }
      }
    } catch {
      print(NSError.define(description: "Can't delete realm files"))
    }
  }
}
