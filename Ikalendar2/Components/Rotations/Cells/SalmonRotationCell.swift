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
      spacing: Scoped.cellSpacing)
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
    .padding(.vertical, Scoped.cellPaddingVertical)
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
            size: Scoped.progressFontSize,
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

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  var body: some View {
    HStack {
      Image(rotation.isCurrent(ikaClock.currentTime) ? .goldenEgg : .salmon)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .frame(height: rowWidth * Scoped.salmonIconHeightRatio)
        .if(rotation.isCurrent(ikaClock.currentTime)) {
          $0
            .adaptiveGlassEffect(in: .circle)
        }
        .scaleEffect(
          rotation.isCurrent(ikaClock.currentTime)
            ? Scoped.iconGoldenEggScaleFactor
            : Scoped.iconSalmonFishScaleFactor)
          .animation(.default, value: rotation.isCurrent(ikaClock.currentTime))

      Spacer()

      HStack(spacing: Scoped.timeTextSpacing) {
        Text(rotation.startTime.toSalmonTimeString(shouldIncludeDate: true))
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.timeTextFontSize,
            relativeTo: .headline)
          .padding(.horizontal, Scoped.timeTextSinglePaddingH)
          .padding(.vertical, Scoped.timeTextSinglePaddingV)
          .adaptiveGlassEffect(in: .rect(cornerRadius: Scoped.timeTextFrameCornerRadius))

        Text("-")
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.timeTextFontSize,
            relativeTo: .headline)

        Text(rotation.endTime.toSalmonTimeString(shouldIncludeDate: true))
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.timeTextFontSize,
            relativeTo: .headline)
          .padding(.horizontal, Scoped.timeTextSinglePaddingH)
          .padding(.vertical, Scoped.timeTextSinglePaddingV)
          .adaptiveGlassEffect(in: .rect(cornerRadius: Scoped.timeTextFrameCornerRadius))
      }
    }
  }
}

#Preview("Current (with reward gear)") {
  List {
    SalmonRotationCell(
      rotation: IkaMockData.getSalmonRotation(rawStartTime: Date()),
      rowWidth: 390)
  }
  .listStyle(.insetGrouped)
  .ikaPreviewEnvironment()
}

#Preview("Future (time only)") {
  List {
    SalmonRotationCell(
      rotation: IkaMockData.getSalmonRotation(
        rawStartTime: Date().addingTimeInterval(48 * 3600),
        hasStageAndWeapons: false),
      rowWidth: 390)
  }
  .listStyle(.insetGrouped)
  .ikaPreviewEnvironment()
}
