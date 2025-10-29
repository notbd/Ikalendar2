//
//  GameMode.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// MARK: - GameMode

/// Data model for the game modes.
enum GameMode: String, Identifiable, CaseIterable, Equatable {
  static let `default`: Self = .battle

  case battle
  case salmon

  var id: String { rawValue }
}

extension GameMode {
  var name: String {
    switch self {
      case .battle: "Battle"
      case .salmon: "Salmon Run"
    }
  }

  var shortName: String {
    switch self {
      case .battle: "Battle"
      case .salmon: "Salmon"
    }
  }
}

extension GameMode {
  var sfSymbolNameSelected: String {
    switch self {
      case .battle: "flag.pattern.checkered"
      case .salmon: "lifepreserver.fill"
    }
  }

  var sfSymbolNameIdle: String {
    switch self {
      case .battle: "flag.pattern.checkered"
      case .salmon: "lifepreserver"
    }
  }
}
