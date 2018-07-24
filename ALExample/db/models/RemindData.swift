//
//  RemindData.swift
//  ALExample
//
//  Created by Lobanov Aleksey on 10/07/2018.
//  Copyright © 2018 Lobanov Aleksey. All rights reserved.
//

import ObjectMapper
import RealmSwift
import SwiftDate
import SwiftyJSON

class RemindData: ALObjectMappable, MappableConvertibleProtocol {
  @objc dynamic var identifier = ALRlmProvider.PrimaryValue.string
  @objc dynamic var title = ""
  @objc dynamic var subtitle = ""
  @objc dynamic var time: Date?
  @objc dynamic var offset = 0

  required convenience init?(map _: Map) {
    self.init()
  }

  override func map(object: [String: Any], context _: Realm) throws {
    let json = JSON(object)
    if identifier == ALRlmProvider.PrimaryValue.string {
      identifier = json["identifier"].stringValue
    }

    title = json["title"].stringValue
    subtitle = json["subtitle"].stringValue
    time = json["time"].stringValue.toISODate()?.date
    offset = json["offset"].intValue
  }

  override func mapping(map: Map) {
    identifier >>> map["identifier"]
    title >>> map["title"]
    subtitle >>> map["subtitle"]
    time?.toISO() >>> map["time"]
    offset >>> map["offset"]
  }

  override static func primaryKey() -> String? {
    return "identifier"
  }
}

struct ReminderModel: Mappable {
  enum Offset: Int {
    case now = 10, min15 = 15, min30 = 30, hour1 = 60
    var messageTitle: String {
      switch self {
      case .now: return "Remind me in 10 seconds"
      case .min15: return "Remind me in 15 seconds"
      case .min30: return "Remind me in 30 seconds"
      case .hour1: return "Remind me in 60 seconds"
      }
    }

    var descrTitle: String {
      switch self {
      case .now: return "At time of event"
      case .min15: return "1 minutes before"
      case .min30: return "30 minutes before"
      case .hour1: return "1 hour before"
      }
    }

    static let all: [Offset] = [.now, .min15, .min30, .hour1]
  }

  var identifier = ""
  var title = ""
  var subtitle = ""
  var time: Date?
  var offset: Offset = .now

  init?(map _: Map) {}

  mutating func mapping(map: Map) {
    let transform = TransformOf<Offset, Int>(fromJSON: { (value: Int?) -> Offset? in
      // transform value from String? to Int?
      Offset(rawValue: value ?? 1)
    }, toJSON: { (value: Offset?) -> Int? in
      // transform value from Int? to String?
      if let value = value {
        return value.rawValue
      }
      return nil
    })

    identifier <- map["identifier"]
    title <- map["title"]
    subtitle <- map["subtitle"]
    time <- (map["time"], ServerDateTransform(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ", gmt: true))
    offset <- (map["offset"], transform)
  }
}
