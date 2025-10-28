//
//  FlatMode.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

//
//  FlatMode.swift
//  Ikalendar2
//
//  Created by Tianwei Zhang on 2025-10-27.
//
import SwiftUI

// MARK: - FlatMode

enum FlatMode: String, Identifiable, CaseIterable, Equatable {
  static let `default`: Self = .regular

  case regular
  case gachi
  case league
  case salmon

  var id: String { rawValue }
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
      case .gachi: "person.fill"
      case .league: "person.2.fill"
      case .salmon: "lifepreserver.fill"
    }
  }

  var sfSymbolNameIdle: String {
    switch self {
      case .regular: "paintbrush"
      case .gachi: "person"
      case .league: "person.2"
      case .salmon: "lifepreserver"
    }
  }
}

extension FlatMode {
  var imgFilnSmall: String { rawValue + "_small" }
}
