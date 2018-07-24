//
//  Reminder+Structures.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 09/07/2018.
//  Copyright (c) 2018 Lobanov Aleksey. All rights reserved.
//
//  In this case:
//    1. `child` module - this develop module
//    2. `parent` module - module or coordinator, that present this develop module
//

import Foundation
import RxSwift

extension ReminderViewModel {

  // MARK: - initial module data

  //   Immutable data, structures, for configure module
  struct ModuleInputData {
  }

  // MARK: - module input structure

  //
  // Examples:
  // 1. Parent module may have send some signals to this
  //   sequence. Child (this) module subscribe to sequence.
  //
  //   var inputSignal:PublishSubject<Bool>
  //

  struct ModuleInput {
  }

  // MARK: - module output structure

  //
  // Examples:
  // 1. Parent module may have subscribe to sequency
  //   below for waitnig data
  //
  //   var result:Observable<LoginResponse>
  //

  struct ModuleOutput {
  }
}
