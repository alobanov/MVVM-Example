//
//  ALSchedulers.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 10/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import Foundation
import RxSwift

public class ALSchedulers {
  public static let sh = ALSchedulers()

  public let background: ImmediateSchedulerType
  public let main: SerialDispatchQueueScheduler

  private init() {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 2
    operationQueue.qualityOfService = .userInitiated
    background = OperationQueueScheduler(operationQueue: operationQueue)
    main = MainScheduler.asyncInstance
  }
}
