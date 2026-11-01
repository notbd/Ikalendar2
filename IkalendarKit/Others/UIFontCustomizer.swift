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
/// UI components like `UINavigationBar` and `UISegmentedControl`.
@MainActor
public enum UIFontCustomizer {
  /// Sets rounded bold large titles and rounded semibold inline titles on every navigation bar.
  static public func customizeNavigationTitleText() {
    let largeTitleFont = customRoundedFont(for: .largeTitle, weight: .bold)
    let titleTextFont = customRoundedFont(for: .title3, weight: .semibold)

    UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeTitleFont]
    UINavigationBar.appearance().titleTextAttributes = [.font: titleTextFont]
  }

  /// Sets rounded 13 pt segmented-control labels: semibold when selected, regular otherwise.
  static public func customizePickerText() {
    let pickerFontSize: CGFloat = 13
    let pickerSelectedFont = customRoundedFont(size: pickerFontSize, weight: .semibold)
    let pickerNormalFont = customRoundedFont(size: pickerFontSize, weight: .regular)

    let segmentedControlAppearance: UISegmentedControl = .appearance()
    segmentedControlAppearance.setTitleTextAttributes(
      [NSAttributedString.Key.font: pickerSelectedFont],
      for: .selected)
    segmentedControlAppearance.setTitleTextAttributes(
      [NSAttributedString.Key.font: pickerNormalFont],
      for: .normal)
  }

  /// Returns the system font at `textStyle`'s size and `weight`, in the rounded design.
  static public func customRoundedFont(for textStyle: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
    let fontSize = UIFont.preferredFont(forTextStyle: textStyle).pointSize
    let systemFont: UIFont = .systemFont(ofSize: fontSize, weight: weight)

    guard let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }

    return UIFont(descriptor: descriptor, size: fontSize)
  }

  /// Returns the system font at `size` and `weight`, in the rounded design.
  static public func customRoundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont: UIFont = .systemFont(ofSize: size, weight: weight)

    guard let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }

    return UIFont(descriptor: descriptor, size: size)
  }
}
