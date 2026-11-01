//
//  FlatMode.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - FlatMode

/// A flattened union of all game and battle modes, so the tab bar and
/// default-mode picker can treat them as one list.
enum FlatMode: String, Identifiable, CaseIterable, Equatable {
  static let `default`: Self = .regular

  case regular
  case gachi
  case league
  case salmon

  var id: String { rawValue }
}

// MARK: - GameMode and BattleMode conversions

extension FlatMode {
  /// The flat mode for a game mode; `battleMode` decides it when the game mode is battle.
  init(gameMode: GameMode, battleMode: BattleMode) {
    switch gameMode {
      case .battle: self.init(battleMode)
      case .salmon: self = .salmon
    }
  }

  init(_ battleMode: BattleMode) {
    switch battleMode {
      case .regular: self = .regular
      case .gachi: self = .gachi
      case .league: self = .league
    }
  }

  var gameMode: GameMode {
    switch self {
      case .regular,
           .gachi,
           .league:
        .battle
      case .salmon:
        .salmon
    }
  }

  /// `nil` for salmon, which has no battle mode.
  var battleMode: BattleMode? {
    switch self {
      case .regular: .regular
      case .gachi: .gachi
      case .league: .league
      case .salmon: nil
    }
  }
}

extension FlatMode {
  var themeColor: Color {
    switch self {
      case .regular: .regularBattleTheme
      case .gachi: .gachiBattleTheme
      case .league: .leagueBattleTheme
      case .salmon: .gachiBattleTheme
    }
  }
}

extension FlatMode {
  var name: String {
    switch self {
      case .regular: "Regular Battle"
      case .gachi: "Ranked Battle"
      case .league: "League Battle"
      case .salmon: "Salmon Run"
    }
  }

  var shortName: String {
    switch self {
      case .regular: "Regular"
      case .gachi: "Ranked"
      case .league: "League"
      case .salmon: "Salmon"
    }
  }
}

extension FlatMode {
  var sfSymbolNameSelected: String {
    switch self {
      case .regular: "paintbrush.fill"
      case .gachi: "trophy.fill"
      case .league: "person.2.fill"
      case .salmon: "lifepreserver.fill"
    }
  }

  var sfSymbolNameIdle: String {
    switch self {
      case .regular: "paintbrush"
      case .gachi: "trophy"
      case .league: "person.2"
      case .salmon: "lifepreserver"
    }
  }
}
