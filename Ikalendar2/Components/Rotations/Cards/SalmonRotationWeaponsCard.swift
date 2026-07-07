//
//  SalmonRotationWeaponsCard.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
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

  @Environment(\.colorScheme) private var colorScheme
  private var colorSchemeAwareGlass: Glass {
    colorScheme == .dark ? .clear : .regular
  }

  let weapon: SalmonWeapon

  var body: some View {
    Image(weapon.imageName)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .shadow(radius: Constants.Style.Global.shadowRadius)
      .padding(Scoped.imgPadding)
      .glassEffect(
        colorSchemeAwareGlass.interactive(),
        in: .rect(cornerRadius: Scoped.frameCornerRadius))
  }
}

#Preview {
  // Enum-case construction: no fail-able-initializer force unwraps in previews.
  SalmonRotationWeaponsCard(weapons: [
    .vanilla(.explosher),
    .vanilla(.dynamoRoller),
    .vanilla(.tentaBrella),
    .mystery(.green),
  ])
  .frame(width: 200, height: 200)
}
