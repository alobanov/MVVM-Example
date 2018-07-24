//
//  ReminderConfigurator.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 09/07/2018.
//  Copyright (c) 2018 Lobanov Aleksey. All rights reserved.
//

import UIKit

class ReminderConfigurator {
  class func configure(
    inputData: ReminderViewModel.ModuleInputData,
    moduleInput: ReminderViewModel.ModuleInput?
  ) throws
    -> (viewController: UIViewController, moduleOutput: ReminderViewModel.ModuleOutput) {
    // View controller
    let viewController = createViewController()

    // Dependencies
    let dependencies = try createDependencies()

    // View model
    let viewModel = ReminderViewModel(dependencies: dependencies, moduleInputData: inputData)
    let moduleOutput = viewModel.configureModule(input: moduleInput)

    viewController.viewModel = viewModel

    return (viewController, moduleOutput)
  }

  private class func createViewController() -> ReminderViewController {
    return ReminderViewController()
  }

  private class func createDependencies() throws -> ReminderViewModel.InputDependencies {
    let provider = ALRlmProvider(container: ReminderDBConfig(name: dbname))

    let reminder = ReminderServiceImp(
      coredataProvider: provider,
      localNotification: LocalNotificationsHelperImp()
    )

    let dependencies = ReminderViewModel.InputDependencies(service: reminder)
    return dependencies
  }

  class func module(data: ReminderViewModel.ModuleInputData) -> (
    viewController: Presentable,
    moduleOutput: ReminderViewModel.ModuleOutput
  )? {
    do {
      let output = try ReminderConfigurator.configure(inputData: data, moduleInput: nil)
      return (output.viewController, output.moduleOutput)
    } catch _ {
      return nil
    }
  }
}
