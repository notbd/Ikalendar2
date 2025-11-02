//
//  IkaAppIcon.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

enum IkaAppIcon: String, CaseIterable, Identifiable {
  static let `default`: Self = .preset

  case preset
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

  var displayNameLocalizedStringKey: LocalizedStringKey {
    switch self {
      case .preset:
        "IkaAppIcon.Preset"
      case .signature:
        "IkaAppIcon.Signature"
      case .outlined:
        "IkaAppIcon.Outlined"
      case .legacy:
        "IkaAppIcon.Legacy"
      case .rick:
        "IkaAppIcon.Rick"
    }
  }

  enum ColorVariant: String, Identifiable, Equatable, CaseIterable {
    case `default`
    case dark
    case clearLight
    case clearDark

    var id: String {
      rawValue
    }

    var displayNameLocalizedStringKey: LocalizedStringKey {
      switch self {
        case .default:
          "IkaAppIcon.ColorVariant.Default"
        case .dark:
          "IkaAppIcon.ColorVariant.Dark"
        case .clearLight:
          "IkaAppIcon.ColorVariant.Clear_Light"
        case .clearDark:
          "IkaAppIcon.ColorVariant.Clear_Dark"
      }
    }

    var codeName: String {
      guard !rawValue.isEmpty else { return "" }

      // Capitalize first letter
      return String(rawValue.prefix(1)).uppercased() + rawValue.dropFirst()
    }

    var index: Int {
      ColorVariant.allCases.firstIndex(of: self)!
    }

    var sfSymbolName: String {
      switch self {
        case .default:
          "sun.max"
        case .dark:
          "moon"
        case .clearLight:
          "sparkles"
        case .clearDark:
          "moon.stars"
      }
    }

    var next: Self {
      switch self {
        case .default:
          .dark
        case .dark:
          .clearLight
        case .clearLight:
          .clearDark
        case .clearDark:
          .default
      }
    }

    init?(index: Int) {
      guard index >= 0, index < ColorVariant.allCases.count else {
        return nil // Index out of bounds
      }

      self = ColorVariant.allCases[index]
    }
  }

  enum DisplaySizeVariant: Equatable {
    case large
    case mid
    case small

    var screenSize: CGFloat {
      switch self {
        case .large:
          120
        case .mid:
          90
        case .small:
          60
      }
    }

    var imageAssetSize: Int {
      switch self {
        case .large:
          256
        case .mid:
          256
        case .small:
          128
      }
    }
  }

  struct DisplayMode: Equatable {
    let color: ColorVariant
    let size: DisplaySizeVariant

    func getImageSuffix() -> String {
      "-iOS-\(color.codeName)-\(size.imageAssetSize)x\(size.imageAssetSize)"
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

  func getImageName(_ displayMode: DisplayMode) -> String {
    iconSetName + displayMode.getImageSuffix()
  }
}
