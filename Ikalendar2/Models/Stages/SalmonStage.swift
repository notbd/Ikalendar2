//
//  SalmonStage.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// MARK: - SalmonStage

/// Data model for the salmon run stages.
enum SalmonStage: Int, Identifiable, CaseIterable, Equatable {
  case spawningGrounds = 5000
  case maroonerSBay = 5001
  case lostOutpost = 5002
  case salmonidSmokeyard = 5003
  case ruinsOfArkPolaris = 5004

  var id: Int { rawValue }
}

/// Fail-able SalmonStage initializer using Stage Name.
extension SalmonStage {
  init?(name: String) {
    switch name {
      case "Spawning Grounds":
        self = .spawningGrounds
      case "Marooner's Bay":
        self = .maroonerSBay
      case "Lost Outpost":
        self = .lostOutpost
      case "Salmonid Smokeyard":
        self = .salmonidSmokeyard
      case "Ruins of Ark Polaris":
        self = .ruinsOfArkPolaris
      default:
        return nil
    }
  }
}

extension SalmonStage {
  var name: String {
    switch self {
      case .spawningGrounds:
        "Spawning Grounds"
      case .maroonerSBay:
        "Marooner's Bay"
      case .lostOutpost:
        "Lost Outpost"
      case .salmonidSmokeyard:
        "Salmonid Smokeyard"
      case .ruinsOfArkPolaris:
        "Ruins of Ark Polaris"
    }
  }
}

extension SalmonStage {
  var imgFiln: String {
    name
      .replacingOccurrences(of: " ", with: "_")
  }

  var imgFilnLarge: String {
    imgFiln + "_Large"
  }
}
