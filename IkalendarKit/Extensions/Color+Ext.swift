//
//  Color+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
  /// A light text color for use on dark backgrounds.
  /// Automatically adapts to the current color scheme.
  static public let lightText: Color = .init(UIColor.lightText)

  /// A dark text color for use on light backgrounds.
  /// Automatically adapts to the current color scheme.
  static public let darkText: Color = .init(UIColor.darkText)

  /// The primary text color for the current interface style.
  /// Use this for main content text that needs to be highly readable.
  static public let label: Color = .init(UIColor.label)

  /// A secondary text color that's slightly less prominent than the primary label.
  /// Use this for secondary content or subtitles.
  static public let secondaryLabel: Color = .init(UIColor.secondaryLabel)

  /// A tertiary text color that's less prominent than secondary labels.
  /// Use this for placeholder text or disabled content.
  static public let tertiaryLabel: Color = .init(UIColor.tertiaryLabel)

  /// The least prominent text color in the label hierarchy.
  /// Use this for the most subtle text elements.
  static public let quaternaryLabel: Color = .init(UIColor.quaternaryLabel)

  /// The primary background color for the current interface style.
  /// Use this as the main background color for your app's content.
  static public let systemBackground: Color = .init(UIColor.systemBackground)

  /// A secondary background color that's subtly different from the primary background.
  /// Use this for content that should be visually separated from the main background.
  static public let systemBackgroundSecondary: Color = .init(UIColor.secondarySystemBackground)

  /// A tertiary background color for additional visual hierarchy.
  /// Use this for nested content or subtle visual separation.
  static public let systemBackgroundTertiary: Color = .init(UIColor.tertiarySystemBackground)

  /// The primary background color for grouped content areas.
  /// Use this for table views, forms, and other grouped interface elements.
  static public let systemGroupedBackground: Color = .init(UIColor.systemGroupedBackground)

  /// A secondary background color for grouped content that needs visual separation.
  /// Use this for cells or sections within grouped interfaces.
  static public let systemGroupedBackgroundSecondary: Color = .init(UIColor.secondarySystemGroupedBackground)

  /// A tertiary background color for additional hierarchy within grouped content.
  /// Use this for nested elements or subtle visual distinctions in grouped interfaces.
  static public let systemGroupedBackgroundTertiary: Color = .init(UIColor.tertiarySystemGroupedBackground)
}
