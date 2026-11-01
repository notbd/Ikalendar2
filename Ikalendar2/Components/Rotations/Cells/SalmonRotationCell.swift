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
        rowWidth: rowWidth,
        isCurrent: rotation.isCurrent(ikaClock.currentTime))

      if hasStageAndWeapon {
        stageAndWeaponSection

        if rotation.isCurrent(ikaClock.currentTime) {
          progressSection
            .transition(.opacity.animation(.default))
        }
      }
    }
    // Workaround (e33efad): List adds its own vertical insets to cells whose content is too
    // short (the time-only rows). Padding every cell the same way keeps row spacing consistent.
    .padding(.vertical, Scoped.cellPaddingV)
    .accessibilityElement(children: .combine)
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
private struct SalmonRotationCellTimeTextSection: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Cell.TimeTextSection

  let rotation: SalmonRotation
  let rowWidth: CGFloat
  /// Passed in by the parent cell (which already reads the clock), so the
  /// clock's per-second ticks do not re-render this section (4d22e88).
  let isCurrent: Bool

  var body: some View {
    HStack {
      Image(isCurrent ? .goldenEgg : .salmon)
        .ikaFitted()
        .accessibilityHidden(true)
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .frame(height: rowWidth * Scoped.salmonIconHeightRatio)
        .if(isCurrent) {
          $0
            .adaptiveGlassEffect(in: .circle)
        }
        .scaleEffect(
          isCurrent
            ? Scoped.iconGoldenEggScaleFactor
            : Scoped.iconSalmonFishScaleFactor)
          .animation(.default, value: isCurrent)

      Spacer()

      HStack(spacing: Scoped.timeTextSpacing) {
        framedTimeText(rotation.startTime.toSalmonTimeString(shouldIncludeDate: true))
        timeText(Text("-"))
        framedTimeText(rotation.endTime.toSalmonTimeString(shouldIncludeDate: true))
      }
    }
  }

  /// A start or end time in its glass frame.
  private func framedTimeText(_ time: String) -> some View {
    timeText(Text(time))
      .padding(.horizontal, Scoped.timeTextSinglePaddingH)
      .padding(.vertical, Scoped.timeTextSinglePaddingV)
      .adaptiveGlassEffect(in: .rect(cornerRadius: Scoped.timeTextFrameCornerRadius))
  }

  private func timeText(_ text: Text) -> some View {
    text
      .scaledLimitedLine()
      .ikaFont(
        .ika2,
        size: Scoped.timeTextFontSize,
        relativeTo: .headline)
  }
}

#Preview("Current (with reward gear)") {
  List {
    SalmonRotationCell(
      rotation: IkaMockData.makeSalmonRotation(rawStartTime: Date()),
      rowWidth: 390)
  }
  .listStyle(.insetGrouped)
  .ikaPreviewEnvironment()
}

#Preview("Future (time only)") {
  List {
    SalmonRotationCell(
      rotation: IkaMockData.makeSalmonRotation(
        rawStartTime: Date().addingTimeInterval(48 * 3600),
        hasStageAndWeapons: false),
      rowWidth: 390)
  }
  .listStyle(.insetGrouped)
  .ikaPreviewEnvironment()
}
