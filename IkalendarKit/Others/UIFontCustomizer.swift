//
//  UIFontCustomizer.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import UIKit

// MARK: - UIFontCustomizer

/// A utility for customizing the appearance of `UIFont` across the application.
///
/// This enum provides static methods to apply consistent font styles to common
/// UI components like `UINavigationBar`.
@MainActor
public enum UIFontCustomizer {
  /// Sets rounded bold large titles and rounded semibold inline titles on every navigation bar.
  static public func customizeNavigationTitleText() {
    let largeTitleFont = customRoundedFont(for: .largeTitle, weight: .bold)
    let titleTextFont = customRoundedFont(for: .title3, weight: .semibold)

    UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeTitleFont]
    UINavigationBar.appearance().titleTextAttributes = [.font: titleTextFont]
  }

  /// Returns the system font at `textStyle`'s size and `weight`, in the rounded design.
  static private func customRoundedFont(for textStyle: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
    let fontSize = UIFont.preferredFont(forTextStyle: textStyle).pointSize
    let systemFont: UIFont = .systemFont(ofSize: fontSize, weight: weight)

    guard let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }

    return UIFont(descriptor: descriptor, size: fontSize)
  }
}
