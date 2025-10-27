//
//  IkaAppIcon.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

enum IkaAppIcon: String, CaseIterable, Identifiable {
  case `default`
  case signature
  case outlined
  case legacy
  case rick

  var id: String { rawValue }

  var alternateIconName: String? {
    switch self {
      case .default:
        nil
      default:
        iconSetName
    }
  }

  var isEasterEgg: Bool {
    self == .rick
  }

  var iconSetName: String {
    "ikalendar2-app-icon-" + rawValue
  }

  var displayName: String {
    switch self {
      case .default:
        "Default"
      case .signature:
        "Signature"
      case .outlined:
        "Outlined"
      case .legacy:
        "Legacy"
      case .rick:
        "Rick"
    }
  }

  enum DisplayMode {
    case large
    case mid
    case small

    var size: CGFloat {
      switch self {
        case .large:
          120
        case .mid:
          90
        case .small:
          60
      }
    }
  }

  var settingsMainSFSymbolName: String {
    switch self {
      case .default:
        "square.3.layers.3d.top.filled"
      case .rick:
        "square.3.layers.3d.bottom.filled"
      default:
        "square.3.layers.3d.middle.filled"
    }
  }

  func getImageName(_ displayMode: IkaAppIcon.DisplayMode) -> String {
    switch displayMode {
      case .large:
        iconSetName + "-iOS-Default-256x256"
      case .mid:
        iconSetName + "-iOS-Default-256x256"
      case .small:
        iconSetName + "-iOS-Default-128x128"
    }
  }
}
