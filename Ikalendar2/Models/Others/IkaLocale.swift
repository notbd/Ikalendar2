//
//  IkaLocale.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - IkaLocale

/// The locales the app knows about, with matching display names and official site links.
enum IkaLocale {
  case en
  case ja
  case zhHans
  case zhHant
  case unknown

  var description: String {
    switch self {
      case .en:
        Constants.Key.Locale.en
      case .ja:
        Constants.Key.Locale.ja
      case .zhHans:
        Constants.Key.Locale.zhHans
      case .zhHant:
        Constants.Key.Locale.zhHant
      case .unknown:
        Constants.Key.Placeholder.unknown
    }
  }

  var sfSymbolName: String {
    switch self {
      case .en:
        "globe.americas.fill"
      default:
        "globe.asia.australia.fill"
    }
  }

  var splatoon2Site: String {
    switch self {
      case .en:
        Constants.Key.URLs.Splatoon2Site.en
      case .ja:
        Constants.Key.URLs.Splatoon2Site.ja
      case .zhHans:
        Constants.Key.URLs.Splatoon2Site.zhHans
      case .zhHant:
        Constants.Key.URLs.Splatoon2Site.zhHant
      case .unknown:
        Constants.Key.URLs.Splatoon2Site.en
    }
  }

  var nintendoSite: String {
    switch self {
      case .en:
        Constants.Key.URLs.NintendoSite.en
      case .ja:
        Constants.Key.URLs.NintendoSite.ja
      case .zhHans:
        Constants.Key.URLs.NintendoSite.zhHans
      case .zhHant:
        Constants.Key.URLs.NintendoSite.zhHant
      case .unknown:
        Constants.Key.URLs.NintendoSite.en
    }
  }

  var easterEggURLString: String {
    switch self {
      case .zhHant:
        Constants.Key.URLs.theGoodStuffCN
      default:
        Constants.Key.URLs.theGoodStuff
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
