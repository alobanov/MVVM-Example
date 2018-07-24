//
//  RealmQueryProvider.swift
//  CoinsBank Beta
//
//  Created by Lobanov Aleksey on 24/02/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import ObjectMapper
import RealmSwift
import RxSwift

public typealias JSONDictionary = [String: Any]
public typealias JSONArrayDictionary = [[String: Any]]
public typealias DictionaryAnyObject = [String: AnyObject]
public typealias DictionaryArray = [[String: AnyObject]]

protocol ALRlmMappable {
  func mapArray<T: ALObjectMappable>(_ type: T.Type, json: JSONArrayDictionary) -> Observable<Void>
  func mapObject<T: ALObjectMappable>(_ type: T.Type, json: JSONDictionary) -> Observable<Void>
}

protocol ALRlmFetchable: ALRlmMappable {
  func models<T: Mappable, O: Object>(type: O.Type, predicate: NSPredicate, sortField: String?, ascending: Bool?) -> [T]?
  func models<T: Mappable, O: Object>(type: O.Type, predicate: NSPredicate) -> [T]?
  func model<T: Mappable, O: Object>(type: O.Type, predicate: NSPredicate) -> T?

  func objects<T: Object>(type: T.Type, predicate: NSPredicate, sortField: String?, ascending: Bool?) -> [T]?
  func objects<T: Object>(type: T.Type, predicate: NSPredicate) -> [T]?
  func objectsRaw<T: Object>(type: T.Type, predicate: NSPredicate, sortField: String?, ascending: Bool?) -> Results<T>?
  func objectsRaw<T: Object>(type: T.Type, predicate: NSPredicate) -> Results<T>?
  func object<T: Object>(type: T.Type, predicate: NSPredicate) -> T?

  func delete<T: Object>(type: T.Type, predicate: NSPredicate) throws
}

class ALRlmProvider: ALRlmFetchable {
  struct PrimaryValue {
    static let int = -1
    static let string = ""
  }

  struct DefaultValues {
    static let string = ""
    static let int = 0
    static let bool = false
    static let double = 0.00000
  }

  let container: ALRlmConfigurator

  init(container: ALRlmConfigurator) {
    self.container = container
  }
}

// MARK: - Queries for working with dictionaries

extension ALRlmMappable where Self: ALRlmProvider {
  func mapObject<T: ALObjectMappable>(_: T.Type, json: JSONDictionary) -> Observable<Void> {
    return Observable<Void>.create { [weak self] observer -> Disposable in
      do {
        guard let realm = self?.container.protectInstance() else {
          let err = NSError.define(description: "Lost database in map object method")
          observer.onError(err)
          return Disposables.create()
        }

        realm.beginWrite()
        let mapper = ALRlmMapper<T>(context: realm)
        let object = try mapper.mapSelf(object: json)
        realm.add(object, update: true)
        try realm.commitWrite()
        observer.onNext(())
        observer.onCompleted()
      } catch {
        let err = NSError.define(description: "Error with serealization: \(NSStringFromClass(T.self))")
        observer.onError(err)
      }

      return Disposables.create()
    }.observeOn(ALSchedulers.sh.main)
  }

  func mapArray<T: ALObjectMappable>(_: T.Type, json: JSONArrayDictionary) -> Observable<Void> {
    return Observable<Void>.create { [weak self] observer -> Disposable in
      do {
        guard let realm = self?.container.protectInstance() else {
          let err = NSError.define(description: "Lost database in map object method")
          observer.onError(err)
          return Disposables.create()
        }

        realm.beginWrite()
        let mapper = ALRlmMapper<T>(context: realm)
        let objects = try mapper.mapArray(objects: json)
        realm.add(objects, update: true)
        try realm.commitWrite()
        observer.onNext(())
        observer.onCompleted()
      } catch {
        let err = NSError.define(description: "Error with serealization: \(NSStringFromClass(T.self))")
        observer.onError(err)
      }

      return Disposables.create()
    }.observeOn(ALSchedulers.sh.main)
  }
}

extension ALRlmProvider {
  func write(_ block: (() throws -> Void)) throws {
    guard let realm = container.protectInstance() else {
      throw NSError.define(description: "Realm not ready")
    }

    do {
      try realm.write(block)
    } catch {
      throw NSError.define(description: "Write error")
    }
  }

  func models<T: Mappable, O: Object>(type: O.Type, predicate: NSPredicate) -> [T]? {
    return models(type: type, predicate: predicate, sortField: nil, ascending: nil)
  }

  func models<T: Mappable, O: Object>(type: O.Type, predicate: NSPredicate, sortField: String? = nil, ascending: Bool? = nil) -> [T]? {
    guard let realm = container.protectInstance() else {
      return nil
    }

    let objects = realm.objects(type.self)
    var filtred = objects.filter(predicate)
    if let sortField = sortField {
      filtred = filtred.sorted(byKeyPath: sortField, ascending: ascending ?? false)
    }
    var result: [T]?
    do {
      try write {
        result = filtred.compactMap { model -> T? in
          if let convertable = model as? MappableConvertibleProtocol {
            return convertable.toMappable() as T?
          }
          return nil
        }
      }
    } catch {
      return nil
    }
    return result
  }

  func model<T: Mappable, O: Object>(type: O.Type, predicate: NSPredicate) -> T? {
    guard let realm = container.protectInstance() else {
      return nil
    }

    let objects = realm.objects(type.self)
    let filtered = objects.filter(predicate)
    var result: T?
    do {
      try write {
        let results = filtered.flatMap { model -> T? in
          if let convertable = model as? MappableConvertibleProtocol {
            return convertable.toMappable() as T?
          }
          return nil
        }
        result = results.first
      }
    } catch {
      return nil
    }
    return result
  }

  func objects<T>(type: T.Type, predicate: NSPredicate) -> [T]? where T: Object {
    return objects(type: type, predicate: predicate, sortField: nil, ascending: nil)
  }

  func objectsRaw<T>(type: T.Type, predicate: NSPredicate) -> Results<T>? where T: Object {
    return objectsRaw(type: type, predicate: predicate, sortField: nil, ascending: nil)
  }

  func objects<T: Object>(type: T.Type, predicate: NSPredicate, sortField: String? = nil, ascending: Bool? = nil) -> [T]? {
    guard let realm = container.protectInstance() else {
      return nil
    }

    let objects = realm.objects(type.self)
    var filtred = objects.filter(predicate)
    if let sortField = sortField {
      filtred = filtred.sorted(byKeyPath: sortField, ascending: ascending ?? false)
    }
    return filtred.compactMap { $0 }
  }

  func objectsRaw<T: Object>(type: T.Type, predicate: NSPredicate, sortField: String? = nil, ascending: Bool? = nil) -> Results<T>? {
    guard let realm = container.protectInstance() else {
      return nil
    }

    let objects = realm.objects(type.self)
    var filtred = objects.filter(predicate)
    if let sortField = sortField {
      filtred = filtred.sorted(byKeyPath: sortField, ascending: ascending ?? false)
    }

    return filtred
  }

  func object<T: Object>(type: T.Type, predicate: NSPredicate) -> T? {
    guard let realm = container.protectInstance() else {
      return nil
    }

    let objects = realm.objects(type.self)
    let filtred = objects.filter(predicate)
    return filtred.first
  }

  func delete<T: Object>(type: T.Type, predicate: NSPredicate) throws {
    guard let realm = container.protectInstance() else {
      return
    }

    let objects = realm.objects(type.self)
    let filtered = objects.filter(predicate)

    try write {
      if !filtered.isEmpty {
        realm.delete(filtered)
      }
    }
  }
}
