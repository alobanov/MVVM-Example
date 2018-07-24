import Foundation
import RxSwift

class RootCoordinator: Coordinator {
  struct Dependencies {
  }

  private let dp: Dependencies
  private let bag = DisposeBag()

  init(router: Router, dependencies: Dependencies) {
    dp = dependencies
    super.init(router: router)
  }

  override func start() {
    showReminder()
  }

  private func showReminder() {
    let data = ReminderViewModel.ModuleInputData()
    guard let module = ReminderConfigurator.module(data: data) else {
      return
    }

    router.setModules([module.viewController])
  }

  override func deepLink(link _: DeepLink) {
  }
}
