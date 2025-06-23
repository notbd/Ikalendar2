//
//  UIFontCustomizer.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Combine
import UIKit

// MARK: - UIFontCustomizer

/// A utility for customizing the appearance of `UIFont` across the application.
///
/// This enum provides static methods to apply consistent font styles to common
/// UI components like `UINavigationBar` and `UISegmentedControl`.
@MainActor
public enum UIFontCustomizer {
  /// Customizes the appearance of navigation title text.
  /// - Note: This function sets the font of the navigation title to a rounded, bold version for large titles
  /// and a rounded, semi-bold version for regular titles.
  static public func customizeNavigationTitleText() {
    let largeTitleFont = UIFontCustomizer.customRoundedFont(for: .largeTitle, weight: .bold)
    let titleTextFont = customRoundedFont(for: .title3, weight: .semibold)

    UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeTitleFont]
    UINavigationBar.appearance().titleTextAttributes = [.font: titleTextFont]
  }

  /// Customizes the appearance of picker text.
  /// - Note: This function sets the font of the picker's selected and normal state to a rounded, semi-bold
  /// and rounded, regular version respectively.
  static public func customizePickerText() {
    let pickerFontSize: CGFloat = 13
    let pickerSelectedFont = customRoundedFont(size: pickerFontSize, weight: .semibold)
    let pickerNormalFont = customRoundedFont(size: pickerFontSize, weight: .regular)

    let segmentedControlAppearance = UISegmentedControl.appearance()
    segmentedControlAppearance.setTitleTextAttributes(
      [NSAttributedString.Key.font: pickerSelectedFont],
      for: .selected)
    segmentedControlAppearance.setTitleTextAttributes(
      [NSAttributedString.Key.font: pickerNormalFont],
      for: .normal)
  }

  /// Helper function to get custom rounded fonts based on text styles.
  /// - Parameters:
  ///   - textStyle: The text style for which to get a rounded font.
  ///   - weight: The weight of the font.
  /// - Returns: A UIFont object that represents the rounded font.
  static public func customRoundedFont(for textStyle: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
    let fontSize = UIFont.preferredFont(forTextStyle: textStyle).pointSize
    let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)

    guard let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }

    return UIFont(descriptor: descriptor, size: fontSize)
  }

  /// Helper function to get custom rounded fonts based on font size and weight.
  /// - Parameters:
  ///   - size: The size of the font.
  ///   - weight: The weight of the font.
  /// - Returns: A UIFont object that represents the rounded font.
  static public func customRoundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
    let systemFont = UIFont.systemFont(ofSize: size, weight: weight)

    guard let descriptor = systemFont.fontDescriptor.withDesign(.rounded) else { return systemFont }

    return UIFont(descriptor: descriptor, size: size)
  }
}
