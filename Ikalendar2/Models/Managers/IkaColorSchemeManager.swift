//
//  IkaColorSchemeManager.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Foundation
import UIKit

/// A singleton color scheme manager that relies on completion handler.
@MainActor
final class IkaColorSchemeManager {
  /// The shared singleton instance
  static let shared = IkaColorSchemeManager()

  enum AppColorScheme: String, Identifiable, CaseIterable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var name: String {
      switch self {
      case .system:
        return "Follow System"
      case .dark:
        return "Dark"
      case .light:
        return "Light"
      }
    }

  }

  // MARK: Lifecycle

  private init() { }

  // MARK: Internal

  func handleColorSchemeChange(for colorScheme: AppColorScheme) {
    let keyWindow =
      UIApplication
        .shared
        .connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }

    switch colorScheme {
    case .system:
      keyWindow?.overrideUserInterfaceStyle = .unspecified
    case .dark:
      keyWindow?.overrideUserInterfaceStyle = .dark
    case .light:
      keyWindow?.overrideUserInterfaceStyle = .light
    }
  }

}
