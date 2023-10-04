//
//  SalmonRotationWeaponsCard.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationWeaponsCard

/// The card component that displays the weapon information of a salmon rotation.
struct SalmonRotationWeaponsCard: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Card.Weapon

  let weapons: [SalmonWeapon]!

  private let columns: [GridItem] = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(Array(weapons.enumerated()), id: \.offset) { _, weapon in
        // enumerate the array identify weapons even with same id (e.g. 4 randoms)
        SalmonRotationWeaponCardIcon(weapon: weapon)
      }
    }
  }
}

// MARK: - SalmonRotationWeaponCardIcon

struct SalmonRotationWeaponCardIcon: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Card.Weapon

  let weapon: SalmonWeapon

  var body: some View {
    Image(weapon.imgFiln)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
      .padding(Scoped.IMG_PADDING)
      .background(Color.systemGroupedBackgroundTertiary)
      .cornerRadius(Scoped.FRAME_CORNER_RADIUS)
  }
}

// MARK: - SalmonRotationWeaponCard_Previews

struct SalmonRotationWeaponCard_Previews: PreviewProvider {
  static var previews: some View {
    SalmonRotationWeaponsCard(weapons: [
      SalmonWeapon(5030)!,
      SalmonWeapon(1020)!,
      SalmonWeapon(310)!,
      SalmonWeapon(-1)!,
    ])
  }
}
