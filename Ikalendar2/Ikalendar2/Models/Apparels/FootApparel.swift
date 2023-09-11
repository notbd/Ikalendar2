//
//  FootApparel.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

// MARK: - FootApparel

/// Data model for the foot apparels.
enum FootApparel: Int, Identifiable, CaseIterable, Equatable {
  case angryRainBoots = 21001
  case nonSlipSenseis = 21002
  case friendshipBracelet = 21004
  case flipperFloppers = 21005
  case woodenSandals = 21006

  var id: Int { rawValue }
}

extension FootApparel {
  var name: String {
    switch self {
    case .angryRainBoots: return "Angry Rain Boots"
    case .nonSlipSenseis: return "Non-slip Senseis"
    case .friendshipBracelet: return "Friendship Bracelet"
    case .flipperFloppers: return "Flipper Floppers"
    case .woodenSandals: return "Wooden Sandals"
    }
  }
}

extension FootApparel {
  var key: String {
    switch self {
    case .angryRainBoots: return "Shs_COP101"
    case .nonSlipSenseis: return "Shs_COP102"
    case .friendshipBracelet: return "Shs_COP104"
    case .flipperFloppers: return "Shs_COP105"
    case .woodenSandals: return "Shs_COP106"
    }
  }
}

extension FootApparel {
  var imgFiln: String {
    let prefix = "S2_Gear_Shoes_"
    let content = name.replacingOccurrences(of: " ", with: "_")
    return prefix + content
  }

  var imgFilnSmall: String { key }
}
