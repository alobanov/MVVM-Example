//
//  Rx+ext.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 09/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import RxSwift

public protocol OptionalType {
  associatedtype Wrapped
  var value: Wrapped? { get }
}

extension Optional: OptionalType {
  public var value: Wrapped? {
    return self
  }
}

public extension Observable where Element: OptionalType {
  func filterNil() -> Observable<Element.Wrapped> {
    return flatMap { (element) -> Observable<Element.Wrapped> in
      if let value = element.value {
        return .just(value)
      } else {
        return .empty()
      }
    }
  }

  func replaceNilWith(_ nilValue: Element.Wrapped) -> Observable<Element.Wrapped> {
    return flatMap { (element) -> Observable<Element.Wrapped> in
      if let value = element.value {
        return .just(value)
      } else {
        return .just(nilValue)
      }
    }
  }

  func mapToVoid() -> Observable<Void> {
    return map({ _ -> Void in
      return
    })
  }
}
