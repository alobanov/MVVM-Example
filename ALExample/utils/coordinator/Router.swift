import UIKit

protocol Routerable: Presentable {
  func presentModal(_ module: Presentable)
  func presentModal(_ module: Presentable, animated: Bool)
//  func presentModal(_ module: Presentable,
//                    animated: Bool,
//                    completion: (() -> Void)?,
//                    animation: HeroDefaultAnimationType)
  func dismissModal()
//  func dismissModal(animated: Bool,
//                    completion: (() -> Void)?,
//                    animation: HeroDefaultAnimationType)

  func push(_ module: Presentable)
//  func push(_ module: Presentable, animated: Bool, animation: HeroDefaultAnimationType)
  func pop()
//  func pop(animated: Bool, animation: HeroDefaultAnimationType)

  func push(_ modules: [Presentable])
  func push(_ modules: [Presentable], animated: Bool)
  func push(_ modules: [Presentable], after: PresentableID)
  func push(_ modules: [Presentable], after: PresentableID, animated: Bool)
  func pop(count: Int)
  func pop(count: Int, animated: Bool)
  func popTo(_ presentId: PresentableID, animated: Bool)

  func setModules(_ modules: [Presentable])
  func setModules(_ modules: [Presentable], hideBar: Bool)
//  func setModules(_ modules: [Presentable], hideBar: Bool, animated: Bool, animation: HeroDefaultAnimationType)

  func popToRootModule(animated: Bool)
  func showTabBar(_ show: Bool)

  func currentPresentableID() -> String?

  func window() -> UIWindow?
}

class Router: Routerable {
  var navigationController: UINavigationController

  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  // MARK: - Modal presentation / dismissal

  func window() -> UIWindow? {
    return UIApplication.shared.keyWindow
  }

  func presentModal(_ module: Presentable) {
//    dismissModal(animated: false, completion: nil, animation: .none)
    presentModal(module, animated: true)
  }

  func presentModal(_ module: Presentable, animated: Bool) {
    navigationController.present(module.presentable(), animated: animated, completion: {})
  }

//  func presentModal(_ module: Presentable,
//                    animated: Bool,
//                    completion: (() -> Void)?,
//                    animation: HeroDefaultAnimationType) {
//    module.presentable().hero.isEnabled = true
//
//    module.presentable().hero.modalAnimationType = animation
//    navigationController.present(module.presentable(), animated: animated, completion: completion)
//  }

  func dismissModal() {
    navigationController.dismiss(animated: true, completion: nil)
  }

//  func dismissModalimmediately() {
//    navigationController.presentedViewController?.hero.isEnabled = false
//    navigationController.dismiss(animated: false, completion: nil)
//  }

//  func dismissModal(animated: Bool,
//                    completion: (() -> Void)?,
//                    animation: HeroDefaultAnimationType) {
//    navigationController.presentedViewController?.hero.isEnabled = true
//    navigationController.presentedViewController?.hero.modalAnimationType = animation
//
//    navigationController.dismiss(animated: animated, completion: completion)
//  }

  // MARK: - push/pop single view controler

  func push(_ module: Presentable) {
    let controller = unwrapPresentable(module)
//    controller.hero.isEnabled = false
//    navigationController.hero.isEnabled = false
    navigationController.pushViewController(controller, animated: true)
  }

//  func push(_ module: Presentable, animated: Bool, animation: HeroDefaultAnimationType) {
//    let controller = unwrapPresentable(module)
//
//    navigationController.hero.navigationAnimationType = animation
  ////    navigationController.hero.isEnabled = true
//
//    navigationController.pushViewController(controller, animated: animated)
//  }

  func push(_ modules: [Presentable]) {
    push(modules, animated: true)
  }

  func pop() {
//    navigationController.hero.isEnabled = false
    navigationController.popViewController(animated: true)
  }

//  func pop(animated: Bool, animation: HeroDefaultAnimationType) {
//    navigationController.hero.navigationAnimationType = animation
//    navigationController.hero.isEnabled = true

//    navigationController.popViewController(animated: animated)
//  }

  // MARK: - push/pop several view controlers

  func push(_ modules: [Presentable], animated: Bool) {
    let controllers = unwrapPresentables(modules)
    let stack = navigationController.viewControllers + controllers
    navigationController.setViewControllers(stack, animated: animated)
  }

  func push(_ modules: [Presentable], after: PresentableID) {
    push(modules, after: after, animated: true)
  }

  func push(_ modules: [Presentable], after: PresentableID, animated: Bool) {
    var stack = navigationController.viewControllers
    let vc = stack.first(where: { vc -> Bool in
      vc.presentId() == after
    })
    if let vc = vc {
      var proceed = true
      while proceed {
        proceed = stack.popLast() == vc
      }
      let controlers = unwrapPresentables(modules)
      stack += controlers
      navigationController.setViewControllers(stack, animated: animated)
    }
  }

  func pop(count: Int) {
    pop(count: count, animated: true)
  }

  func pop(count: Int, animated: Bool) {
    var stack = navigationController.viewControllers
    var popCount = count
    while !stack.isEmpty && popCount > 0 {
      stack.removeLast()
      popCount -= 1
    }
    navigationController.setViewControllers(stack, animated: animated)
  }

  func popTo(_ presentId: PresentableID, animated: Bool) {
    let vc = navigationController.viewControllers.first { vc -> Bool in
      return vc.presentId() == presentId
    }
    if let vc = vc {
      navigationController.popToViewController(vc, animated: animated)
    }
  }

  // MARK: - replace full navigation stack

  func setModules(_ modules: [Presentable]) {
    setModules(modules, hideBar: false)
  }

  func setModules(_ modules: [Presentable], hideBar: Bool) {
    let controllers = unwrapPresentables(modules)
    navigationController.setViewControllers(controllers, animated: true)
    navigationController.isNavigationBarHidden = hideBar
  }

//  func setModules(_ modules: [Presentable], hideBar: Bool, animated: Bool, animation: HeroDefaultAnimationType) {
//    let controllers = unwrapPresentables(modules)
//
//    navigationController.hero.isEnabled = true
//    navigationController.hero.navigationAnimationType = animation
//
//    navigationController.setViewControllers(controllers, animated: animated)
//    navigationController.isNavigationBarHidden = hideBar
//  }

  // MARK: - Utility

  func popToRootModule(animated: Bool) {
    navigationController.popToRootViewController(animated: animated)
  }

  func showTabBar(_ show: Bool) {
    let showBlock = { [weak self] in
      self?.navigationController.tabBarController?.tabBar.alpha = 1
    }
    let hideBlock = { [weak self] in
      self?.navigationController.tabBarController?.tabBar.alpha = 0
    }
    UIView.animate(withDuration: 0.3) {
      show ? showBlock() : hideBlock()
    }
  }

  private func unwrapPresentables(_ modules: [Presentable]) -> [UIViewController] {
    let controllers = modules.map { module -> UIViewController in
      return unwrapPresentable(module)
    }
    return controllers
  }

  private func unwrapPresentable(_ module: Presentable) -> UIViewController {
    let controller = module.presentable()
    if controller is UINavigationController {
      assertionFailure("Forbidden push UINavigationController.")
    }
    return controller
  }

  func currentPresentableID() -> String? {
    return navigationController.visibleViewController?.presentId()
  }

  // MARK: - Presentable

  func presentable() -> UIViewController {
    return navigationController
  }

  func presentId() -> String {
    return navigationController.presentId()
  }

  static func presentId() -> String {
    return UINavigationController.presentId()
  }
}
