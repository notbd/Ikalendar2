//
//  MysteryWeapon.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// MARK: - MysteryWeapon

/// Data model for the mystery weapons.
enum MysteryWeapon: Int, Identifiable, CaseIterable, Equatable {
  case green = -1
  case gold = -2

  var id: Int { rawValue }
}

extension MysteryWeapon {
  var name: String {
    switch self {
      case .green:
        "Mystery"
      case .gold:
        "Mystery Grizzco"
    }
  }
}

extension MysteryWeapon {
  var key: String {
    switch self {
      case .green:
        "Mystery"
      case .gold:
        "Mystery Grizzco"
    }
  }
}

extension MysteryWeapon {
  var imgFiln: String { name.replacingOccurrences(of: " ", with: "_") }
  var imgFilnSmall: String { imgFiln }
}
