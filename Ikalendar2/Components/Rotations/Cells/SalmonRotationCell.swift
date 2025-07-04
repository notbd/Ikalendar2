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
@MainActor
struct SalmonRotationCell: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Cell

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

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

        if rotation.isCurrent(ikaTimePublisher.currentTime) {
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
      SalmonRotationWeaponsCard(weapons: rotation.weapons!)
    }
  }

  private var progressSection: some View {
    ProgressView(
      value: min(ikaTimePublisher.currentTime, rotation.endTime) - rotation.startTime,
      total: rotation.endTime - rotation.startTime,
      label: {
        Text(ikaTimePublisher.currentTime.toTimeRemainingStringKey(until: rotation.endTime))
          .contentTransition(.numericText(countsDown: true))
          .animation(.snappy, value: ikaTimePublisher.currentTime)
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
@MainActor
struct SalmonRotationCellTimeTextSection: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Cell.TimeTextSection

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  var body: some View {
    HStack {
      Image(rotation.isCurrent(ikaTimePublisher.currentTime) ? .goldenEgg : .salmon)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .frame(height: rowWidth * Scoped.SALMON_ICON_HEIGHT_RATIO)
        .scaleEffect(
          rotation.isCurrent(ikaTimePublisher.currentTime)
            ? Scoped.ICON_GOLDEN_EGG_SCALE_FACTOR
            : Scoped.ICON_SALMON_FISH_SCALE_FACTOR)
          .animation(.default, value: rotation.isCurrent(ikaTimePublisher.currentTime))

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
          .background(Color.systemGroupedBackgroundTertiary)
          .cornerRadius(Scoped.TIME_TEXT_FRAME_CORNER_RADIUS)

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
          .background(Color.systemGroupedBackgroundTertiary)
          .cornerRadius(Scoped.TIME_TEXT_FRAME_CORNER_RADIUS)
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
