//
//  BattleMode.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleMode

/// Data model for the battle modes.
enum BattleMode: String, Identifiable, CaseIterable, Equatable {
  case regular
  case gachi
  case league

  var id: String { rawValue }
}

extension BattleMode {
  var themeColor: Color {
    switch self {
    case .regular: .regularBattleTheme
    case .gachi: .gachiBattleTheme
    case .league: .leagueBattleTheme
    }
  }
}

extension BattleMode {
  var name: String {
    switch self {
    case .regular: "Regular Battle"
    case .gachi: "Ranked Battle"
    case .league: "League Battle"
    }
  }

  var shortName: String {
    switch self {
    case .regular: "Regular"
    case .gachi: "Ranked"
    case .league: "League"
    }
  }
}

extension BattleMode {
  var sfSymbolNameSelected: String {
    switch self {
    case .regular: "paintbrush.fill"
    case .gachi: "person.fill"
    case .league: "person.3.fill"
    }
  }

  var sfSymbolNameIdle: String {
    switch self {
    case .regular: "paintbrush"
    case .gachi: "person"
    case .league: "person.3"
    }
  }
}

extension BattleMode {
  var imgFilnSmall: String { rawValue + "_small" }
  var imgFilnMid: String { rawValue + "_mid" }
  var imgFilnLarge: String { rawValue + "_large" }
}
