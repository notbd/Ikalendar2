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

  @EnvironmentObject var ikaTimePublisher: IkaTimePublisher

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  private var hasStageAndWeapon: Bool { rotation.stage != nil && rotation.weapons != nil }
  private var isCurrent: Bool { rotation.isCurrent(currentTime: ikaTimePublisher.currentTime) }

  private var stageHeight: CGFloat {
    rowWidth * Scoped.STAGE_HEIGHT_RATIO + Scoped.STAGE_HEIGHT_ADJUSTMENT_CONSTANT
  }

  var body: some View {
    VStack(
      alignment: .leading,
      spacing: Scoped.CELL_SPACING)
    {
      SalmonRotationCellTimeTextSection(
        iconName: "salmon",
        rotation: rotation,
        rowWidth: rowWidth)

      if hasStageAndWeapon {
        stageAndWeaponSection

        if isCurrent {
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
        rowWidth: stageHeight * (16 / 9))
        .frame(height: stageHeight)
      Spacer()
      SalmonRotationWeaponCard(weapons: rotation.weapons)
        .frame(width: stageHeight)
    }
  }

  private var progressSection: some View {
    ProgressView(
      value: ikaTimePublisher.currentTime - rotation.startTime,
      total: rotation.endTime - rotation.startTime,
      label: {
        HStack {
          Spacer()
          Text(ikaTimePublisher.currentTime.toTimeRemainingString(until: rotation.endTime))
            .scaledLimitedLine()
            .fontIka(
              .ika2,
              size: Scoped.PROGRESS_FONT_SIZE,
              relativeTo: .headline)
        }
      })
  }
}

// MARK: - SalmonRotationCellTimeTextSection

/// A HStack component containing the time text of a salmon rotation.
struct SalmonRotationCellTimeTextSection: View {
  typealias Scoped = Constants.Styles.Rotation.Salmon.Cell.TimeTextSection

  @EnvironmentObject var ikaTimePublisher: IkaTimePublisher

  let iconName: String
  let rotation: SalmonRotation
  let rowWidth: CGFloat

  var body: some View {
    HStack {
      Image(iconName)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
        .frame(width: rowWidth * Scoped.SALMON_ICON_WIDTH_RATIO)

      Spacer()

      HStack(spacing: Scoped.TIME_TEXT_SPACING) {
        Text(rotation.startTime.toSalmonTimeString(
          includingDate: true,
          currentTime: ikaTimePublisher.currentTime))
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

        Text(rotation.endTime.toSalmonTimeString(
          includingDate: true,
          currentTime: ikaTimePublisher.currentTime))
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
