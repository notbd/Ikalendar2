//
//  IkaColorSchemeManager.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation
import UIKit

/// `IkaColorSchemeManager` is a singleton class responsible for managing the color scheme of the application.
/// It provides an interface to switch between different color modes (light, dark, or system) and ensures
/// smooth transitions between these states.
@MainActor
final class IkaColorSchemeManager {
  static let shared: IkaColorSchemeManager = .init()

  enum PreferredColorScheme: String, Identifiable, CaseIterable {
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

  /// A computed property that returns the key window from the connected scenes.
  private var keyWindow: UIWindow? {
    UIApplication
      .shared
      .connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }

  private init() { }

  /// Changes the app's color scheme according to the given colorScheme.
  ///
  /// - Parameter preferredColorScheme: The desired color scheme: system, dark, or light.
  /// - Note: The transition between the color schemes is animated for a smooth user experience.
  func handlePreferredColorSchemeChange(for preferredColorScheme: PreferredColorScheme) {
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
