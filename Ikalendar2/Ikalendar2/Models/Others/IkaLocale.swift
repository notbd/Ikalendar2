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
      Constants.Key.Locale.EN
    case .ja:
      Constants.Key.Locale.JA
    case .zhHans:
      Constants.Key.Locale.ZH_HANS
    case .zhHant:
      Constants.Key.Locale.ZH_HANT
    case .unknown:
      Constants.Key.Placeholder.UNKNOWN
    }
  }

  var splatoon2Site: String {
    switch self {
    case .en:
      Constants.Key.URL.Splatoon2Site.EN
    case .ja:
      Constants.Key.URL.Splatoon2Site.JA
    case .zhHans:
      Constants.Key.URL.Splatoon2Site.ZH_HANS
    case .zhHant:
      Constants.Key.URL.Splatoon2Site.ZH_HANT
    case .unknown:
      Constants.Key.URL.Splatoon2Site.EN
    }
  }

  var nintendoSite: String {
    switch self {
    case .en:
      Constants.Key.URL.NintendoSite.EN
    case .ja:
      Constants.Key.URL.NintendoSite.JA
    case .zhHans:
      Constants.Key.URL.NintendoSite.ZH_HANS
    case .zhHant:
      Constants.Key.URL.NintendoSite.ZH_HANT
    case .unknown:
      Constants.Key.URL.NintendoSite.EN
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
