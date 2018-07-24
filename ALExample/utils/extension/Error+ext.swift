import Foundation

public extension NSError {
  public static func define(description: String, failureReason: String = "", code: Int = 0) -> NSError {
    let userInfo = [
      NSLocalizedDescriptionKey: description,
      NSLocalizedFailureReasonErrorKey: failureReason
    ]

    let domain = Bundle.main.bundleIdentifier ?? "ru.lobanov"
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }

  public static func define(description: String, code: Int = 0) -> NSError {
    let userInfo = [
      NSLocalizedDescriptionKey: description
    ]

    let domain = Bundle.main.bundleIdentifier ?? "ru.lobanov"
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }
}
