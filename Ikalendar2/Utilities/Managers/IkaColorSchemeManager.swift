//
//  IkaColorSchemeManager.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import UIKit

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

// MARK: - IkaColorSchemeManager

/// Stateless utility that applies the preferred color scheme to the key window with a
/// cross-dissolve, so a scheme flip does not pop.
@MainActor
enum IkaColorSchemeManager {
  static private var keyWindow: UIWindow? {
    UIApplication
      .shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }

  static func handlePreferredColorSchemeChange(for preferredColorScheme: IkaPreferredColorScheme) {
    guard let keyWindow else { return }

    UIView.transition(
      with: keyWindow,
      duration: 0.25,
      options: .transitionCrossDissolve,
      animations: {
        switch preferredColorScheme {
          case .system:
            keyWindow.overrideUserInterfaceStyle = .unspecified
          case .dark:
            keyWindow.overrideUserInterfaceStyle = .dark
          case .light:
            keyWindow.overrideUserInterfaceStyle = .light
        }
      },
      completion: nil)
  }
}
