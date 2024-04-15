//
//  BodyApparel.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

// MARK: - BodyApparel

/// Data model for the body apparels.
enum BodyApparel: Int, Identifiable, CaseIterable, Equatable {
  case squiddorPolo = 21000
  case anchorLifeVest = 21001
  case juiceParka = 21002
  case gardenGear = 21003
  case crustwearXXL = 21004
  case northCountryParka = 21005
  case recordShopLookEP = 21007
  case devUniform = 21008
  case officeAttire = 21009
  case srlCoat = 21010

  var id: Int { rawValue }
}

extension BodyApparel {
  var name: String {
    switch self {
      case .squiddorPolo: "Squiddor Polo"
      case .anchorLifeVest: "Anchor Life Vest"
      case .juiceParka: "Juice Parka"
      case .gardenGear: "Garden Gear"
      case .crustwearXXL: "Crustwear XXL"
      case .northCountryParka: "North-Country Parka"
      case .recordShopLookEP: "Record Shop Look EP"
      case .devUniform: "Dev Uniform"
      case .officeAttire: "Office Attire"
      case .srlCoat: "SRL Coat"
    }
  }
}

extension BodyApparel {
  var key: String {
    switch self {
      case .squiddorPolo: "Clt_COP100"
      case .anchorLifeVest: "Clt_COP101"
      case .juiceParka: "Clt_COP102"
      case .gardenGear: "Clt_COP103"
      case .crustwearXXL: "Clt_COP104"
      case .northCountryParka: "Clt_COP105"
      case .recordShopLookEP: "Clt_COP107"
      case .devUniform: "Clt_COP108"
      case .officeAttire: "Clt_COP109"
      case .srlCoat: "Clt_COP110"
    }
  }
}

extension BodyApparel {
  var imgFiln: String {
    let prefix = "S2_Gear_Clothing_"
    let content = name.replacingOccurrences(of: " ", with: "_")
    return prefix + content
  }

  var imgFilnSmall: String { key }
}
