//
//  BattleRotationCell.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationCellPrimary

/// The primary version of a cell component for the battle rotation that takes
/// all the space in the list content.
struct BattleRotationCellPrimary: View {
  typealias Scoped = Constants.Styles.Rotation.Battle.Cell.Primary

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @EnvironmentObject var ikaTimePublisher: IkaTimePublisher
  @EnvironmentObject var ikaPreference: IkaPreference

  var rotation: BattleRotation
  var width: CGFloat

  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .center) {
        ruleSection
        Spacer()
        remainingTimeSection
      }

      ProgressView(
        value: ikaTimePublisher.currentTime - rotation.startTime,
        total: rotation.endTime - rotation.startTime)
        .padding(.top, Scoped.PROGRESS_BAR_PADDING_TOP)
        .padding(.bottom, Scoped.PROGRESS_BAR_PADDING_BOTTOM)

      HStack(
        alignment: .center,
        spacing: width * Scoped.STAGE_SECTION_SPACING_RATIO)
      {
        BattleRotationStageCardPrimary(stage: rotation.stageA)
        BattleRotationStageCardPrimary(stage: rotation.stageB)
      }
    }
    .padding(.top, Scoped.CELL_PADDING_TOP)
    .padding(.bottom, Scoped.CELL_PADDING_BOTTOM)
  }

  // MARK: Rule Section

  var ruleSection: some View {
    HStack(
      alignment: .center,
      spacing: Scoped.RULE_SECTION_SPACING)
    {
      // Rule icon
      Image(rotation.rule.imgFilnMid)
        .resizable()
        .antialiased(true)
        .scaledToFit()
        .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
        .frame(maxWidth: width * Scoped.RULE_IMG_MAX_WIDTH_RATIO)

      // Rule title
      Text(rotation.rule.name.localizedStringKey())
        .scaledLimitedLine()
        .fontIka(
          .ika2,
          size: isHorizontalCompact
            ? Scoped.RULE_FONT_SIZE_COMPACT
            : Scoped.RULE_FONT_SIZE_REGULAR)
    }
    .frame(height: width * Scoped.RULE_SECTION_HEIGHT_RATIO)
  }

  // MARK: Remaining Time Section

  var remainingTimeSection: some View {
    HStack {
      Spacer()
      HStack {
        Spacer()
        Text(ikaTimePublisher.currentTime.toTimeRemainingString(until: rotation.endTime))
          .scaledLimitedLine()
          .foregroundColor(.secondary)
          .fontIka(
            .ika2,
            size: width * Scoped.REMAINING_TIME_FONT_RATIO)
      }
      .frame(maxWidth: width * Scoped.REMAINING_TIME_TEXT_MAX_WIDTH_RATIO)
    }
    .frame(width: width * Scoped.REMAINING_TIME_SECTION_WIDTH_RATIO)
  }
}

// MARK: - BattleRotationCellSecondary

/// The secondary version of a cell component for the battle rotation
/// that takes all the space in a list unit.
struct BattleRotationCellSecondary: View {
  typealias Scoped = Constants.Styles.Rotation.Battle.Cell.Secondary

  @EnvironmentObject var ikaPreference: IkaPreference

  var rotation: BattleRotation
  var width: CGFloat

  var body: some View {
    HStack {
      // MARK: Rule section

      VStack(spacing: Scoped.RULE_SECTION_SPACING) {
        // Rule img
        Image(rotation.rule.imgFilnMid)
          .resizable()
          .antialiased(true)
          .scaledToFit()
          .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
          .frame(maxWidth: width * Scoped.RULE_IMG_MAX_WIDTH)
          .padding(Scoped.RULE_IMG_PADDING)
          .background(Color.tertiarySystemGroupedBackground)
          .cornerRadius(Scoped.RULE_IMG_FRAME_CORNER_RADIUS)

        // Rule title
        Text(rotation.rule.name.localizedStringKey())
          .scaledLimitedLine()
          .fontIka(.ika2, size: Scoped.RULE_FONT_SIZE)
          .frame(height: Scoped.RULE_TITLE_HEIGHT)
      }
      .frame(maxWidth: width * Scoped.RULE_SECTION_WIDTH_RATIO)
      .padding(.trailing, Scoped.RULE_SECTION_PADDING_TRAILING)

      // MARK: Stage Section

      HStack(
        alignment: .center,
        spacing: width * Scoped.STAGE_SECTION_SPACING_RATIO +
          Scoped.STAGE_SECTION_SPACING_ADJUSTMENT_CONSTANT)
      {
        BattleRotationStageCardSecondary(stage: rotation.stageA)
        BattleRotationStageCardSecondary(stage: rotation.stageB)
      }
    }
  }
}

// MARK: - BattleRotationCell_Previews

struct BattleRotationCell_Previews: PreviewProvider {
  static var previews: some View {
    GeometryReader { geo in
      List {
        Section {
          BattleRotationCellPrimary(
            rotation: IkaMockData.getBattleRotation(
              rule: .towerControl,
              rawStartTime: Date()),
            width: geo.size.width)
        }
        Section {
          BattleRotationCellSecondary(
            rotation: IkaMockData.getBattleRotation(
              rule: .clamBlitz,
              rawStartTime: Date()),
            width: geo.size.width)
        }
      }
      .listStyle(InsetGroupedListStyle())
    }
  }
}
