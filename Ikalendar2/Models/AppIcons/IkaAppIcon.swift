//
//  IkaAppIcon.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

enum IkaAppIcon: String, CaseIterable, Identifiable {
  case modernDark
  case modernLight
  case monoDark
  case monoLight
  case legacy
  case rick

  var id: String { rawValue }

  var alternateIconName: String? {
    switch self {
    case .modernDark:
      return nil
    default:
      return iconSetName
    }
  }

  var iconSetName: String {
    switch self {
    case .modernDark:
      return "app-icon-modern-dark"
    case .modernLight:
      return "app-icon-modern-light"
    case .monoDark:
      return "app-icon-mono-dark"
    case .monoLight:
      return "app-icon-mono-light"
    case .legacy:
      return "app-icon-legacy"
    case .rick:
      return "app-icon-rick"
    }
  }

  var displayName: String {
    switch self {
    case .modernDark:
      return "Modern Dark"
    case .modernLight:
      return "Modern Light"
    case .monoDark:
      return "Mono Dark"
    case .monoLight:
      return "Mono Light"
    case .legacy:
      return "Legacy"
    case .rick:
      return "Rick"
    }
  }

  var imageName: String {
    "ikalendar2-" + iconSetName
  }

  var imageNameSmall: String {
    imageName + "-small"
  }

  // MARK: Internal

  static func clipShape(cornerRadius: CGFloat) -> some Shape {
    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
  }
}
