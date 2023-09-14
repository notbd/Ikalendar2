//
//  IkaLocale.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - IkaLocale

enum IkaLocale {
  case en
  case ja
  case zhHans
  case zhHant
  case unknown

  var description: String {
    switch self {
    case .en:
      return Constants.Key.Locale.EN
    case .ja:
      return Constants.Key.Locale.JA
    case .zhHans:
      return Constants.Key.Locale.ZH_HANS
    case .zhHant:
      return Constants.Key.Locale.ZH_HANT
    case .unknown:
      return Constants.Key.Placeholder.UNKNOWN
    }
  }
}

extension IkaLocale {
  init(locale: Locale) {
    if locale.identifier.hasPrefix("en") { self = .en }
    else if locale.identifier.hasPrefix("ja") { self = .ja }
    else if locale.identifier.hasPrefix("zh_Hans") { self = .zhHans }
    else if locale.identifier.hasPrefix("zh_Hant") { self = .zhHant }
    else { self = .unknown }
  }
}

extension Locale {
  func toIkaLocale() -> IkaLocale {
    IkaLocale(locale: self)
  }
}