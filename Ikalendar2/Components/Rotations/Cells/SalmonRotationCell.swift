//
//  SalmonRotationCell.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationCell

/// The view for the salmon rotation info that takes the entire space in the list content.
struct SalmonRotationCell: View {
  typealias Scoped = Constants.Styles.Rotation.Salmon.Cell

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  private var hasStageAndWeapon: Bool { rotation.stage != nil && rotation.weapons != nil }

  private var stageHeight: CGFloat {
    rowWidth * Scoped.STAGE_HEIGHT_RATIO + Scoped.STAGE_HEIGHT_ADJUSTMENT_CONSTANT
  }

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

        if rotation.isCurrent() {
          progressSection
        }
      }
    }
    .if(hasStageAndWeapon) {
      $0.padding(.top, Scoped.CELL_PADDING_TOP)
        .padding(.bottom, Scoped.CELL_PADDING_BOTTOM)
    }
  }

  private var stageAndWeaponSection: some View {
    HStack {
      SalmonRotationStageCard(
        rotation: rotation,
        cardWidth: stageHeight * (16 / 9))
        .frame(height: stageHeight)
        .layoutPriority(2)
      Spacer()
      SalmonRotationWeaponCard(weapons: rotation.weapons)
        .layoutPriority(1)
    }
  }

  private var progressSection: some View {
    ProgressView(
      value: min(ikaTimePublisher.currentTime, rotation.endTime) - rotation.startTime,
      total: rotation.endTime - rotation.startTime,
      label: {
        Text(ikaTimePublisher.currentTime.toTimeRemainingString(until: rotation.endTime))
          .scaledLimitedLine()
          .fontIka(
            .ika2,
            size: Scoped.PROGRESS_FONT_SIZE,
            relativeTo: .headline)
          .hAlignment(.trailing)
      })
  }
}

// MARK: - SalmonRotationCellTimeTextSection

/// A HStack component containing the time text of a salmon rotation.
struct SalmonRotationCellTimeTextSection: View {
  typealias Scoped = Constants.Styles.Rotation.Salmon.Cell.TimeTextSection

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  var body: some View {
    HStack {
      Image("salmon")
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
        .frame(width: rowWidth * Scoped.SALMON_ICON_WIDTH_RATIO)

      Spacer()

      HStack(spacing: Scoped.TIME_TEXT_SPACING) {
        Text(rotation.startTime.toSalmonTimeString(includingDate: true))
          .scaledLimitedLine()
          .fontIka(
            .ika2,
            size: Scoped.TIME_TEXT_FONT_SIZE,
            relativeTo: .headline)
          .padding(.horizontal, Scoped.TIME_TEXT_SINGLE_PADDING_HORIZONTAL)
          .background(Color.tertiarySystemGroupedBackground)
          .cornerRadius(Scoped.TIME_TEXT_FRAME_CORNER_RADIUS)

        Text("-")
          .scaledLimitedLine()
          .fontIka(
            .ika2,
            size: Scoped.TIME_TEXT_FONT_SIZE,
            relativeTo: .headline)

        Text(rotation.endTime.toSalmonTimeString(includingDate: true))
          .scaledLimitedLine()
          .fontIka(
            .ika2,
            size: Scoped.TIME_TEXT_FONT_SIZE,
            relativeTo: .headline)
          .padding(.horizontal, Scoped.TIME_TEXT_SINGLE_PADDING_HORIZONTAL)
          .background(Color.tertiarySystemGroupedBackground)
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
