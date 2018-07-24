//
//  Coordinator.swift
//  Puls
//
//  Created by MOPC on 19/06/2017.
//  Copyright © 2017 MOPC. All rights reserved.
//

import Foundation

protocol Coordinatorable: Presentable {
  func start()
  func deepLink(link: DeepLink)
}
