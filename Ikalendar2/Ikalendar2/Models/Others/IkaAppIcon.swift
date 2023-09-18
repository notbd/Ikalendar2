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
      nil
    default:
      iconSetName
    }
  }

  var iconSetName: String {
    switch self {
    case .modernDark:
      "app-icon-modern-dark"
    case .modernLight:
      "app-icon-modern-light"
    case .monoDark:
      "app-icon-mono-dark"
    case .monoLight:
      "app-icon-mono-light"
    case .legacy:
      "app-icon-legacy"
    case .rick:
      "app-icon-rick"
    }
  }

  var displayName: String {
    switch self {
    case .modernDark:
      "Modern Dark"
    case .modernLight:
      "Modern Light"
    case .monoDark:
      "Mono Dark"
    case .monoLight:
      "Mono Light"
    case .legacy:
      "Legacy"
    case .rick:
      "Rick"
    }
  }

  enum DisplayMode {
    case original
    case mid
    case small

    var sideLen: CGFloat {
      switch self {
      case .original:
        1024
      case .mid:
        120
      case .small:
        60
      }
    }

    var cornerRadius: CGFloat {
      switch self {
      case .original:
        1024 * (14 / 60)
      case .mid:
        28
      case .small:
        14
      }
    }

    var clipShape: some Shape {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
  }

  // MARK: Internal

  func getSettingsSFSymbolName() -> String {
    switch self {
    case .modernDark:
      "square.3.layers.3d.top.filled"
    case .rick:
      "square.3.layers.3d.bottom.filled"
    default:
      "square.3.layers.3d.middle.filled"
    }
  }

  func getImageName(_ displayMode: IkaAppIcon.DisplayMode) -> String {
    switch displayMode {
    case .original:
      "ikalendar2-" + iconSetName
    case .mid:
      "ikalendar2-" + iconSetName + "-mid"
    case .small:
      "ikalendar2-" + iconSetName + "-small"
    }
  }
}
