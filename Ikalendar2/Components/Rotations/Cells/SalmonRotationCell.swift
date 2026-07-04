//
//  SalmonRotationCell.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import IkalendarKit
import SwiftUI

// MARK: - SalmonRotationCell

/// The view for the salmon rotation info that takes the entire space in the list content.
struct SalmonRotationCell: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Cell

  @Environment(IkaClock.self) private var ikaClock

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  private var hasStageAndWeapon: Bool { rotation.stage != nil && rotation.weapons != nil }

  var body: some View {
    VStack(
      alignment: .leading,
      spacing: Scoped.CELL_SPACING)
    {
      SalmonRotationCellTimeTextSection(
        rotation: rotation,
        rowWidth: rowWidth)

      if hasStageAndWeapon {
        stageAndWeaponSection

        if rotation.isCurrent(ikaClock.currentTime) {
          progressSection
            .transition(.opacity.animation(.default))
        }
      }
    }
    // Stupid workaround because SwiftUI List cell force adds vInsets for content that's too small
    .padding(.vertical, Scoped.CELL_PADDING_VERTICAL)
  }

  private var stageAndWeaponSection: some View {
    SalmonStageAndWeaponsLayout {
      SalmonRotationStageCard(rotation: rotation)
      SalmonRotationWeaponsCard(weapons: rotation.weapons ?? [])
    }
  }

  private var progressSection: some View {
    ProgressView(
      value: min(ikaClock.currentTime, rotation.endTime) - rotation.startTime,
      total: rotation.endTime - rotation.startTime,
      label: {
        Text(ikaClock.currentTime.toTimeRemainingStringKey(until: rotation.endTime))
          .contentTransition(.numericText(countsDown: true))
          .animation(.snappy, value: ikaClock.currentTime)
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.PROGRESS_FONT_SIZE,
            relativeTo: .headline)
          .hAlignment(.trailing)
      })
      .tint(.accentColor)
  }
}

// MARK: - SalmonRotationCellTimeTextSection

/// A HStack component containing the time text of a salmon rotation.
struct SalmonRotationCellTimeTextSection: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Cell.TimeTextSection

  @Environment(IkaClock.self) private var ikaClock

  @Environment(\.colorScheme) private var colorScheme
  private var colorSchemeAwareGlass: Glass {
    colorScheme == .dark ? .clear : .regular
  }

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  var body: some View {
    HStack {
      Image(rotation.isCurrent(ikaClock.currentTime) ? .goldenEgg : .salmon)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .frame(height: rowWidth * Scoped.SALMON_ICON_HEIGHT_RATIO)
        .if(rotation.isCurrent(ikaClock.currentTime)) {
          $0
            .glassEffect(
              colorSchemeAwareGlass.interactive(),
              in: .circle)
        }
        .scaleEffect(
          rotation.isCurrent(ikaClock.currentTime)
            ? Scoped.ICON_GOLDEN_EGG_SCALE_FACTOR
            : Scoped.ICON_SALMON_FISH_SCALE_FACTOR)
          .animation(.default, value: rotation.isCurrent(ikaClock.currentTime))

      Spacer()

      HStack(spacing: Scoped.TIME_TEXT_SPACING) {
        Text(rotation.startTime.toSalmonTimeString(shouldIncludeDate: true))
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.TIME_TEXT_FONT_SIZE,
            relativeTo: .headline)
          .padding(.horizontal, Scoped.TIME_TEXT_SINGLE_PADDING_H)
          .padding(.vertical, Scoped.TIME_TEXT_SINGLE_PADDING_V)
          .glassEffect(
            colorSchemeAwareGlass.interactive(),
            in: .rect(cornerRadius: Scoped.TIME_TEXT_FRAME_CORNER_RADIUS))

        Text("-")
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.TIME_TEXT_FONT_SIZE,
            relativeTo: .headline)

        Text(rotation.endTime.toSalmonTimeString(shouldIncludeDate: true))
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.TIME_TEXT_FONT_SIZE,
            relativeTo: .headline)
          .padding(.horizontal, Scoped.TIME_TEXT_SINGLE_PADDING_H)
          .padding(.vertical, Scoped.TIME_TEXT_SINGLE_PADDING_V)
          .glassEffect(
            colorSchemeAwareGlass.interactive(),
            in: .rect(cornerRadius: Scoped.TIME_TEXT_FRAME_CORNER_RADIUS))
      }
    }
  }
}

// MARK: - SalmonRotationCell_Previews

struct SalmonRotationCell_Previews: PreviewProvider {
  static var previews: some View {
    SalmonRotationCell(
      rotation: IkaMockData.getSalmonRotation(),
      rowWidth: 390)
  }
}
