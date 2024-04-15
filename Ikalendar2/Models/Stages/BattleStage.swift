//
//  BattleStage.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// MARK: - BattleStage

/// Data model for the battle stages.
enum BattleStage: String, Identifiable, CaseIterable, Equatable {
  case anchoVGames = "Ancho-V Games"
  case arowanaMall = "Arowana Mall"
  case blackbellySkatepark = "Blackbelly Skatepark"
  case campTriggerfish = "Camp Triggerfish"
  case gobyArena = "Goby Arena"
  case humpbackPumpTrack = "Humpback Pump Track"
  case inkblotArtAcademy = "Inkblot Art Academy"
  case kelpDome = "Kelp Dome"
  case makoMart = "MakoMart"
  case mantaMaria = "Manta Maria"
  /// #10
  case morayTowers = "Moray Towers"
  case musselforgeFitness = "Musselforge Fitness"
  case newAlbacoreHotel = "New Albacore Hotel"
  case piranhaPit = "Piranha Pit"
  case portMackerel = "Port Mackerel"
  case shellendorfInstitute = "Shellendorf Institute"
  case shiftyStation = "Shifty Station"
  case skipperPavilion = "Skipper Pavilion"
  case snapperCanal = "Snapper Canal"
  case starfishMainstage = "Starfish Mainstage"
  /// #20
  case sturgeonShipyard = "Sturgeon Shipyard"
  case theReef = "The Reef"
  case wahooWorld = "Wahoo World"
  case walleyeWarehouse = "Walleye Warehouse"

  var id: String { rawValue }
}

extension BattleStage {
  var name: String {
    switch self {
      case .anchoVGames: "Ancho-V Games"
      case .arowanaMall: "Arowana Mall"
      case .blackbellySkatepark: "Blackbelly Skatepark"
      case .campTriggerfish: "Camp Triggerfish"
      case .gobyArena: "Goby Arena"
      case .humpbackPumpTrack: "Humpback Pump Track"
      case .inkblotArtAcademy: "Inkblot Art Academy"
      case .kelpDome: "Kelp Dome"
      case .makoMart: "MakoMart"
      case .mantaMaria: "Manta Maria"
      // #10
      case .morayTowers: "Moray Towers"
      case .musselforgeFitness: "Musselforge Fitness"
      case .newAlbacoreHotel: "New Albacore Hotel"
      case .piranhaPit: "Piranha Pit"
      case .portMackerel: "Port Mackerel"
      case .shellendorfInstitute: "Shellendorf Institute"
      case .shiftyStation: "Shifty Station"
      case .skipperPavilion: "Skipper Pavilion"
      case .snapperCanal: "Snapper Canal"
      case .starfishMainstage: "Starfish Mainstage"
      // #20
      case .sturgeonShipyard: "Sturgeon Shipyard"
      case .theReef: "The Reef"
      case .wahooWorld: "Wahoo World"
      case .walleyeWarehouse: "Walleye Warehouse"
    }
  }
}

extension BattleStage {
  var releaseDate: String {
    switch self {
      case .anchoVGames: "08/01/2018"
      case .arowanaMall: "02/02/2018"
      case .blackbellySkatepark: "02/02/2017"
      case .campTriggerfish: "04/25/2018"
      case .gobyArena: "03/02/2018"
      case .humpbackPumpTrack: "07/21/2017"
      case .inkblotArtAcademy: "07/21/2017"
      case .kelpDome: "09/16/2017"
      case .makoMart: "11/25/2017"
      case .mantaMaria: "08/26/2017"
      // #10
      case .morayTowers: "07/21/2017"
      case .musselforgeFitness: "07/21/2017"
      case .newAlbacoreHotel: "07/01/2018"
      case .piranhaPit: "03/31/2018"
      case .portMackerel: "07/21/2017"
      case .shellendorfInstitute: "01/12/2018"
      case .shiftyStation: "08/04/2017"
      case .skipperPavilion: "10/03/2018"
      case .snapperCanal: "10/06/2017"
      case .starfishMainstage: "07/21/2017"
      // #20
      case .sturgeonShipyard: "07/21/2017"
      case .theReef: "07/21/2017"
      case .wahooWorld: "06/01/2018"
      case .walleyeWarehouse: "12/15/2017"
    }
  }
}

extension BattleStage {
  var inkableArea: Int {
    switch self {
      case .anchoVGames: 2642
      case .arowanaMall: 2391
      case .blackbellySkatepark: 2583
      case .campTriggerfish: 2338
      case .gobyArena: 2221
      case .humpbackPumpTrack: 2248
      case .inkblotArtAcademy: 2468
      case .kelpDome: 2147
      case .makoMart: 2167
      case .mantaMaria: 2356
      // #10
      case .morayTowers: 2212
      case .musselforgeFitness: 1958
      case .newAlbacoreHotel: 2405
      case .piranhaPit: 3081
      case .portMackerel: 2457
      case .shellendorfInstitute: 2052
      case .shiftyStation: 2011
      case .skipperPavilion: 2439
      case .snapperCanal: 2247
      case .starfishMainstage: 2320
      // #20
      case .sturgeonShipyard: 2356
      case .theReef: 2908
      case .wahooWorld: 2858
      case .walleyeWarehouse: 1632
    }
  }
}

extension BattleStage {
  var imgFiln: String { rawValue.replacingOccurrences(of: " ", with: "_") }
}
