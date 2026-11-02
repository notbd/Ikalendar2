//
//  IkaColorSchemeManager.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import UIKit

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
      duration: Constants.Motion.colorSchemeCrossDissolve,
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
