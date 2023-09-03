//
//  SalmonApparel.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - SalmonApparelInfo

/// A wrapper data model for the salmon run reward apparel + its available time.
struct SalmonApparelInfo {
  let apparel: SalmonApparel
  let availableTime: Date
}

// MARK: - SalmonApparel

/// Data model for the salmon run reward apparels.
enum SalmonApparel: Equatable {
  case head(HeadApparel)
  case body(BodyApparel)
  case foot(FootApparel)

  enum ApparelType {
    case head
    case body
    case foot
  }

  // MARK: Lifecycle

  init?(
    type: ApparelType,
    id: Int)
  {
    switch type {
    case .head:
      guard let apparel = HeadApparel(rawValue: id) else { return nil }
      self = .head(apparel)
    case .body:
      guard let apparel = BodyApparel(rawValue: id) else { return nil }
      self = .body(apparel)
    case .foot:
      guard let apparel = FootApparel(rawValue: id) else { return nil }
      self = .foot(apparel)
    }
  }
}

extension SalmonApparel {
  var name: String {
    switch self {
    case .head(let apparel):
      return apparel.name
    case .body(let apparel):
      return apparel.name
    case .foot(let apparel):
      return apparel.name
    }
  }

  var key: String {
    switch self {
    case .head(let apparel):
      return apparel.key
    case .body(let apparel):
      return apparel.key
    case .foot(let apparel):
      return apparel.key
    }
  }

  var imgFiln: String {
    switch self {
    case .head(let apparel):
      return apparel.imgFiln
    case .body(let apparel):
      return apparel.imgFiln
    case .foot(let apparel):
      return apparel.imgFiln
    }
  }

  var imgFilnSmall: String {
    switch self {
    case .head(let apparel):
      return apparel.imgFilnSmall
    case .body(let apparel):
      return apparel.imgFilnSmall
    case .foot(let apparel):
      return apparel.imgFilnSmall
    }
  }
}
