//
//  HeadApparel.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// MARK: - HeadApparel

/// Data model for the head apparels.
enum HeadApparel: Int, Identifiable, CaseIterable, Equatable {
  case headlampHelmet = 21000
  case dustBlocker2000 = 21001
  case weldingMask = 21002
  case beekeeperHat = 21003
  case octoleetGoggles = 21004
  case capOfLegend = 21005
  case oceanicHardHat = 21006
  case workersHeadTowel = 21007
  case workersCap = 21008
  case sailorCap = 21009

  var id: Int { rawValue }
}

extension HeadApparel {
  var name: String {
    switch self {
      case .headlampHelmet: "Headlamp Helmet"
      case .dustBlocker2000: "Dust Blocker 2000"
      case .weldingMask: "Welding Mask"
      case .beekeeperHat: "Beekeeper Hat"
      case .octoleetGoggles: "Octoleet Goggles"
      case .capOfLegend: "Cap of Legend"
      case .oceanicHardHat: "Oceanic Hard Hat"
      case .workersHeadTowel: "Worker's Head Towel"
      case .workersCap: "Worker's Cap"
      case .sailorCap: "Sailor Cap"
    }
  }
}

extension HeadApparel {
  var key: String {
    switch self {
      case .headlampHelmet: "Hed_COP100"
      case .dustBlocker2000: "Hed_COP101"
      case .weldingMask: "Hed_COP102"
      case .beekeeperHat: "Hed_COP103"
      case .octoleetGoggles: "Hed_COP104"
      case .capOfLegend: "Hed_COP105"
      case .oceanicHardHat: "Hed_COP106"
      case .workersHeadTowel: "Hed_COP107"
      case .workersCap: "Hed_COP108"
      case .sailorCap: "Hed_COP109"
    }
  }
}

extension HeadApparel {
  var imgFiln: String {
    let prefix = "S2_Gear_Headgear_"
    let content = name.replacingOccurrences(of: " ", with: "_")
    return prefix + content
  }

  var imgFilnSmall: String { key }
}
