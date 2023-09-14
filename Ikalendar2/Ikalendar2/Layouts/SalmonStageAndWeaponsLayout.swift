//
//  SalmonStageAndWeaponsLayout.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// A custom layout for the section containing the stage card and the weapon cards.
///
/// Lays out the stage card and the weapon card horizontally with default spacing.
/// The stage card will receive a proposed size of 16:9 aspect ratio.
/// The weapon card will receive a proposed size of 1:1 aspect ratio.
///
/// - Precondition:
///   - The proposed width must already be set.
///   - Must have exactly two subviews: one for the stage and one for the weapons.
struct SalmonStageAndWeaponsLayout: Layout {

  // MARK: Internal

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ())
    -> CGSize
  {
    guard proposal.width != nil else { return .zero }
    guard subviews.count == 2 else { return .zero }

    let hSpacings = getHSpacings(subviews: subviews)
    let correctHeight = (proposal.width! - hSpacings[0]) * (9 / (16 + 9))

    return CGSize(
      width: proposal.width!,
      height: correctHeight)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ())
  {
    guard proposal.width != nil else { return }
    guard subviews.count == 2 else { return }

    let hSpacings = getHSpacings(subviews: subviews)
    let correctHeight = (proposal.width! - hSpacings[0]) * (9 / (16 + 9))

    let stageHeight = correctHeight
    let stageWidth = stageHeight * (16 / 9)
    let stageCenterX = bounds.minX + stageWidth * (1 / 2)
    let stageCenterY = bounds.midY

    let weaponHeight = correctHeight
    let weaponWidth = weaponHeight
    let weaponCenterX = bounds.maxX - weaponWidth * (1 / 2)
    let weaponCenterY = bounds.midY

    // placing stage card
    subviews[0].place(
      at: CGPoint(x: stageCenterX, y: stageCenterY),
      anchor: .center,
      proposal: ProposedViewSize(
        width: stageWidth,
        height: stageHeight))

    // placing weapon card
    subviews[1].place(
      at: CGPoint(x: weaponCenterX, y: weaponCenterY),
      anchor: .center,
      proposal: ProposedViewSize(
        width: weaponWidth,
        height: weaponHeight))
  }

  // MARK: Private

  private func getHSpacings(subviews: Subviews) -> [CGFloat] {
    subviews.indices.map { index in
      guard index < subviews.count - 1 else { return 0 }
      return subviews[index].spacing.distance(
        to: subviews[index + 1].spacing,
        along: .horizontal)
    }
  }

}
