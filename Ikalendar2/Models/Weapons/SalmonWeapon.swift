//
//  SalmonWeapon.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

// MARK: - SalmonWeapon

/// Wrapper data model for all of the salmon run weapons.
/// Not CaseIterable.
enum SalmonWeapon: Equatable {
  case vanilla(IkaWeapon)
  case mystery(MysteryWeapon)
}

/// Fail-able SalmonWeapon initializer using id.
extension SalmonWeapon {
  init?(_ id: Int) {
    if id >= 0 {
      guard let weapon = IkaWeapon(rawValue: id) else {
        return nil
      }
      self = .vanilla(weapon)
    }
    else {
      guard let weapon = MysteryWeapon(rawValue: id) else {
        return nil
      }
      self = .mystery(weapon)
    }
  }
}

extension SalmonWeapon {
  var name: String {
    switch self {
      case .vanilla(let weapon):
        weapon.name
      case .mystery(let weapon):
        weapon.name
    }
  }

  var key: String {
    switch self {
      case .vanilla(let weapon):
        weapon.key
      case .mystery(let weapon):
        weapon.key
    }
  }

  var imgFiln: String {
    switch self {
      case .vanilla(let weapon):
        weapon.imgFiln
      case .mystery(let weapon):
        weapon.imgFiln
    }
  }

  var imgFilnSmall: String {
    switch self {
      case .vanilla(let weapon):
        weapon.imgFilnSmall
      case .mystery(let weapon):
        weapon.imgFilnSmall
    }
  }
}
