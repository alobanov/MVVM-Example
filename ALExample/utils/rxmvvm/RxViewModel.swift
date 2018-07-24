//
//  RxViewModel.swift
//  CoinsBank
//
//  Created by MOPC on 08.09.16.
//  Copyright © 2016 CoinsBank. All rights reserved.
//

import Foundation
import RxSwift

protocol RxViewModelType {
  associatedtype InputDependencies
  associatedtype Input
  associatedtype Output

  func configure(input: Input) -> Output
}

protocol RxViewModelModuleType {
  associatedtype ModuleInput
  associatedtype ModuleOutput

  func configureModule(input: ModuleInput?) -> ModuleOutput
}
