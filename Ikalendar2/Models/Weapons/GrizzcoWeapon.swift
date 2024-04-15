//
//  GrizzcoWeapon.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - GrizzcoWeapon

/// Data model for the grizzco weapons.
enum GrizzcoWeapon: Int, Identifiable, CaseIterable, Equatable {
  case blaster = 20000
  case brella = 20010
  case charger = 20020
  case slosher = 20030

  var id: Int { rawValue }
}

extension GrizzcoWeapon {
  var name: String {
    switch self {
      case .blaster: "Grizzco Blaster"
      case .brella: "Grizzco Brella"
      case .charger: "Grizzco Charger"
      case .slosher: "Grizzco Slosher"
    }
  }
}

extension GrizzcoWeapon {
  var key: String {
    switch self {
      case .blaster: "Wst_Shooter_BlasterCoopBurst"
      case .brella: "Wst_Umbrella_CoopAutoAssault"
      case .charger: "Wst_Charger_CoopSpark"
      case .slosher: "Wst_Slosher_CoopVase"
    }
  }
}

extension GrizzcoWeapon {
  var imgFiln: String {
    let prefix = "S2_Weapon_Main_"
    let content = name.replacingOccurrences(of: " ", with: "_")
    return prefix + content
  }

  var imgFilnSmall: String { key }
}
