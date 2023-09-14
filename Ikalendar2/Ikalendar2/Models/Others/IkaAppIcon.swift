//
//  IkaAppIcon.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

enum IkaAppIcon: String, CaseIterable, Identifiable {
  static let defaultIcon = IkaAppIcon.modernDark

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

  enum DisplayMode {
    case original
    case mid
    case small

    var sideLen: CGFloat {
      switch self {
      case .original:
        return 1024
      case .mid:
        return 120
      case .small:
        return 60
      }
    }

    var cornerRadius: CGFloat {
      switch self {
      case .original:
        return 1024 * (14 / 60)
      case .mid:
        return 28
      case .small:
        return 14
      }
    }

    var clipShape: some Shape {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
  }

  var settingsSFSymbolName: String {
    switch self {
    case .modernDark:
      return "square.3.layers.3d.top.filled"
    case .rick:
      return "square.3.layers.3d.bottom.filled"
    default:
      return "square.3.layers.3d.middle.filled"
    }
  }

  // MARK: Internal

  func getImageName(_ displayMode: IkaAppIcon.DisplayMode) -> String {
    switch displayMode {
    case .original:
      return "ikalendar2-" + iconSetName
    case .mid:
      return "ikalendar2-" + iconSetName + "-mid"
    case .small:
      return "ikalendar2-" + iconSetName + "-small"
    }
  }
}
