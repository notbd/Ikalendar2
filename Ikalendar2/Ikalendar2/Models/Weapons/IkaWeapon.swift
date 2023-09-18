//
//  IkaWeapon.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

// MARK: - IkaWeapon

/// Data model for the normal weapons.
enum IkaWeapon: Int, Identifiable, CaseIterable, Equatable {
  /// Shooters
  case splooshOMatic = 0
  case splattershotJr = 10
  case splashOMatic = 20
  case aerosprayMG = 30
  case splattershot = 40
  case gal52 = 50
  case nZap85 = 60
  case splattershotPro = 70
  case gal96 = 80
  case jetSquelcher = 90
  /// Blasters
  case lunaBlaster = 200
  case blaster = 210
  case rangeBlaster = 220
  case clashBlaster = 230
  case rapidBlaster = 240
  case rapidBlasterPro = 250
  /// Nozzlenoses
  case l3Nozzlenose = 300
  case h3Nozzlenose = 310
  /// Squeezer
  case squeezer = 400
  /// Rollers
  case carbonRoller = 1000
  case splatRoller = 1010
  case dynamoRoller = 1020
  case flingzaRoller = 1030
  case inkbrush = 1100
  case octobrush = 1110
  /// Chargers
  case classicSquiffer = 2000
  case splatCharger = 2010
  case splatterscope = 2020
  case eliter4K = 2030
  case eliter4KScope = 2040
  case bamboozler14MkI = 2050
  case gooTuber = 2060
  /// Sloshers
  case slosher = 3000
  case triSlosher = 3010
  case sloshingMachine = 3020
  case bloblobber = 3030
  case explosher = 3040
  /// Splatlings
  case miniSplatling = 4000
  case heavySplatling = 4010
  case hydraSplatling = 4020
  case ballpointSplatling = 4030
  case nautilus47 = 4040
  /// Dualies
  case dappleDualies = 5000
  case splatDualies = 5010
  case gloogaDualies = 5020
  case dualieSquelchers = 5030
  case darkTetraDualies = 5040
  /// Brellas
  case splatBrella = 6000
  case tentaBrella = 6010
  case undercoverBrella = 6020

  var id: Int { rawValue }
}

extension IkaWeapon {
  var name: String {
    switch self {
    // Shooters
    case .splooshOMatic: "Sploosh-o-matic"
    case .splattershotJr: "Splattershot Jr."
    case .splashOMatic: "Splash-o-matic"
    case .aerosprayMG: "Aerospray MG"
    case .splattershot: "Splattershot"
    case .gal52: ".52 Gal"
    case .nZap85: "N-ZAP '85"
    case .splattershotPro: "Splattershot Pro"
    case .gal96: ".96 Gal"
    case .jetSquelcher: "Jet Squelcher"
    // Blasters
    case .lunaBlaster: "Luna Blaster"
    case .blaster: "Blaster"
    case .rangeBlaster: "Range Blaster"
    case .clashBlaster: "Clash Blaster"
    case .rapidBlaster: "Rapid Blaster"
    case .rapidBlasterPro: "Rapid Blaster Pro"
    // Nozzlenoses
    case .l3Nozzlenose: "L-3 Nozzlenose"
    case .h3Nozzlenose: "H-3 Nozzlenose"
    // Squeezer
    case .squeezer: "Squeezer"
    // Rollers
    case .carbonRoller: "Carbon Roller"
    case .splatRoller: "Splat Roller"
    case .dynamoRoller: "Dynamo Roller"
    case .flingzaRoller: "Flingza Roller"
    case .inkbrush: "Inkbrush"
    case .octobrush: "Octobrush"
    // Chargers
    case .classicSquiffer: "Classic Squiffer"
    case .splatCharger: "Splat Charger"
    case .splatterscope: "Splatterscope"
    case .eliter4K: "E-liter 4K"
    case .eliter4KScope: "E-liter 4K Scope"
    case .bamboozler14MkI: "Bamboozler 14 Mk I"
    case .gooTuber: "Goo Tuber"
    // Sloshers
    case .slosher: "Slosher"
    case .triSlosher: "Tri-Slosher"
    case .sloshingMachine: "Sloshing Machine"
    case .bloblobber: "Bloblobber"
    case .explosher: "Explosher"
    // Splatlings
    case .miniSplatling: "Mini Splatling"
    case .heavySplatling: "Heavy Splatling"
    case .hydraSplatling: "Hydra Splatling"
    case .ballpointSplatling: "Ballpoint Splatling"
    case .nautilus47: "Nautilus 47"
    // Dualies
    case .dappleDualies: "Dapple Dualies"
    case .splatDualies: "Splat Dualies"
    case .gloogaDualies: "Glooga Dualies"
    case .dualieSquelchers: "Dualie Squelchers"
    case .darkTetraDualies: "Dark Tetra Dualies"
    // Brellas
    case .splatBrella: "Splat Brella"
    case .tentaBrella: "Tenta Brella"
    case .undercoverBrella: "Undercover Brella"
    }
  }
}

extension IkaWeapon {
  var key: String {
    switch self {
    // Shooters
    case .splooshOMatic: "Wst_Shooter_Short_00"
    case .splattershotJr: "Wst_Shooter_First_00"
    case .splashOMatic: "Wst_Shooter_Precision_00"
    case .aerosprayMG: "Wst_Shooter_Blaze_00"
    case .splattershot: "Wst_Shooter_Normal_00"
    case .gal52: "Wst_Shooter_Gravity_00"
    case .nZap85: "Wst_Shooter_QuickMiddle_00"
    case .splattershotPro: "Wst_Shooter_Expert_00"
    case .gal96: "Wst_Shooter_Heavy_00"
    case .jetSquelcher: "Wst_Shooter_Long_00"
    // Blasters
    case .lunaBlaster: "Wst_Shooter_BlasterShort_00"
    case .blaster: "Wst_Shooter_BlasterMiddle_00"
    case .rangeBlaster: "Wst_Shooter_BlasterLong_00"
    case .clashBlaster: "Wst_Shooter_BlasterLightShort_00"
    case .rapidBlaster: "Wst_Shooter_BlasterLight_00"
    case .rapidBlasterPro: "Wst_Shooter_BlasterLightLong_00"
    // Nozzlenoses
    case .l3Nozzlenose: "Wst_Shooter_TripleQuick_00"
    case .h3Nozzlenose: "Wst_Shooter_TripleMiddle_00"
    // Squeezer
    case .squeezer: "Wst_Shooter_Flash_00"
    // Rollers
    case .carbonRoller: "Wst_Roller_Compact_00"
    case .splatRoller: "Wst_Roller_Normal_00"
    case .dynamoRoller: "Wst_Roller_Heavy_00"
    case .flingzaRoller: "Wst_Roller_Hunter_00"
    case .inkbrush: "Wst_Roller_BrushMini_00"
    case .octobrush: "Wst_Roller_BrushNormal_00"
    // Chargers
    case .classicSquiffer: "Wst_Charger_Quick_00"
    case .splatCharger: "Wst_Charger_Normal_00"
    case .splatterscope: "Wst_Charger_NormalScope_00"
    case .eliter4K: "Wst_Charger_Long_00"
    case .eliter4KScope: "Wst_Charger_LongScope_00"
    case .bamboozler14MkI: "Wst_Charger_Light_00"
    case .gooTuber: "Wst_Charger_Keeper_00"
    // Sloshers
    case .slosher: "Wst_Slosher_Strong_00"
    case .triSlosher: "Wst_Slosher_Diffusion_00"
    case .sloshingMachine: "Wst_Slosher_Launcher_00"
    case .bloblobber: "Wst_Slosher_Bathtub_00"
    case .explosher: "Wst_Slosher_Washtub_00"
    // Splatlings
    case .miniSplatling: "Wst_Spinner_Quick_00"
    case .heavySplatling: "Wst_Spinner_Standard_00"
    case .hydraSplatling: "Wst_Spinner_Hyper_00"
    case .ballpointSplatling: "Wst_Spinner_Downpour_00"
    case .nautilus47: "Wst_Spinner_Serein_00"
    // Dualies
    case .dappleDualies: "Wst_Twins_Short_00"
    case .splatDualies: "Wst_Twins_Normal_00"
    case .gloogaDualies: "Wst_Twins_Gallon_00"
    case .dualieSquelchers: "Wst_Twins_Dual_00"
    case .darkTetraDualies: "Wst_Twins_Stepper_00"
    // Brellas
    case .splatBrella: "Wst_Umbrella_Normal_00"
    case .tentaBrella: "Wst_Umbrella_Wide_00"
    case .undercoverBrella: "Wst_Umbrella_Compact_00"
    }
  }
}

extension IkaWeapon {
  var imgFiln: String {
    let prefix = "S2_Weapon_Main_"
    let content = name.replacingOccurrences(of: " ", with: "_")
    return prefix + content
  }

  var imgFilnSmall: String { key }
}
