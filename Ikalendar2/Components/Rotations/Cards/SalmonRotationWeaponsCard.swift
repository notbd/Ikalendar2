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

  let weapons: [SalmonWeapon]

  private let columns: [GridItem] = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    LazyVGrid(columns: columns) {
      ForEach(Array(weapons.enumerated()), id: \.offset) { _, weapon in
        // Keyed by position: a rotation can list the same weapon more than once (e.g. four gold mystery weapons).
        SalmonRotationWeaponCardIcon(weapon: weapon)
      }
    }
  }
}

// MARK: - SalmonRotationWeaponCardIcon

private struct SalmonRotationWeaponCardIcon: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Card.Weapon

  let weapon: SalmonWeapon

  var body: some View {
    Image(weapon.imageName)
      .ikaFitted()
      .shadow(radius: Constants.Style.Global.shadowRadius)
      .padding(Scoped.imagePadding)
      .adaptiveGlassEffect(in: .rect(cornerRadius: Scoped.frameCornerRadius))
      .accessibilityLabel(Text(weapon.name.localizedStringKey))
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
