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
    guard let stage = Self.allCases.first(where: { $0.name == name })
    else { return nil }

    self = stage
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
  var imageName: String {
    name
      .replacing(" ", with: "_")
  }

  var imageNameLarge: String {
    imageName + "_Large"
  }
}
