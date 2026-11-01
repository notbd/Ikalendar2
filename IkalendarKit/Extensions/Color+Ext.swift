//
//  Color+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
  /// The primary background color for the current interface style.
  /// Use this as the main background color for your app's content.
  static public let systemBackground: Color = .init(UIColor.systemBackground)

  /// The primary background color for grouped content areas.
  /// Use this for table views, forms, and other grouped interface elements.
  static public let systemGroupedBackground: Color = .init(UIColor.systemGroupedBackground)

  /// A tertiary background color for additional hierarchy within grouped content.
  /// Use this for nested elements or subtle visual distinctions in grouped interfaces.
  static public let systemGroupedBackgroundTertiary: Color = .init(UIColor.tertiarySystemGroupedBackground)
}
