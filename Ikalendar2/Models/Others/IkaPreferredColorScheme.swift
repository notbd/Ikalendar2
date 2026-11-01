//
//  IkaPreferredColorScheme.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - IkaPreferredColorScheme

/// The color scheme options the user can pick from: follow the system, or force dark / light.
enum IkaPreferredColorScheme: String, Identifiable, CaseIterable {
  static let `default`: Self = .dark

  case system
  case dark
  case light

  var id: String { rawValue }

  var name: String {
    switch self {
      case .system:
        "Follow System"
      case .dark:
        "Dark"
      case .light:
        "Light"
    }
  }

  var sfSymbolName: String {
    switch self {
      case .system:
        "macbook.and.iphone"
      case .dark:
        "moon.fill"
      case .light:
        "sun.max.fill"
    }
  }
}
