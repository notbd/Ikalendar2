//
//  BattleRotationCell.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationCell

struct BattleRotationCell: View {
  enum CellType {
    case primary
    case secondary
  }

  let type: CellType
  let rotation: BattleRotation
  let rowWidth: CGFloat

  var body: some View {
    switch type {
    case .primary:
      BattleRotationCellPrimary(
        rotation: rotation,
        rowWidth: rowWidth)
    case .secondary:
      BattleRotationCellSecondary(
        rotation: rotation,
        rowWidth: rowWidth)
    }
  }
}

// MARK: - BattleRotationCellPrimary

/// The primary version of a cell component for the battle rotation that takes
/// all the space in the list content.
struct BattleRotationCellPrimary: View {
  typealias Scoped = Constants.Styles.Rotation.Battle.Cell.Primary

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  @State private var ruleIconHeight: CGFloat = .zero // initial value does not matter
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  let rotation: BattleRotation
  let rowWidth: CGFloat

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
        spacing: rowWidth * Scoped.STAGE_SECTION_SPACING_RATIO)
      {
        BattleRotationStageCardPrimary(
          stage: rotation.stageA,
          altImageName: rotation.stageAltImageNameA)
        BattleRotationStageCardPrimary(
          stage: rotation.stageB,
          altImageName: rotation.stageAltImageNameB)
      }
    }
    .padding(.top, Scoped.CELL_PADDING_TOP)
    .padding(.bottom, Scoped.CELL_PADDING_BOTTOM)
  }

  // MARK: Rule Section

  private var ruleSection: some View {
    HStack(
      alignment: .center,
      spacing: Scoped.RULE_SECTION_SPACING)
    {
      // Rule icon
      Image(rotation.rule.imgFilnMid)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
        .frame(maxWidth: rowWidth * Scoped.RULE_IMG_MAX_WIDTH_RATIO)
        .background(
          GeometryReader { geo in
            Color.clear.onAppear {
              ruleIconHeight = geo.size.height
            }
          })

      // Rule title
      Text(rotation.rule.name.localizedStringKey)
        .scaledLimitedLine()
        .fontIka(
          .ika2,
          size: isHorizontalCompact
            ? Scoped.RULE_FONT_SIZE_COMPACT
            : Scoped.RULE_FONT_SIZE_REGULAR,
          relativeTo: .title)
        .frame(maxHeight: ruleIconHeight)
    }
    .frame(
      maxWidth: rowWidth * Scoped.RULE_SECTION_MAX_WIDTH_RATIO,
      alignment: .leading)
  }

  // MARK: Remaining Time Section

  private var remainingTimeSection: some View {
    Text(ikaTimePublisher.currentTime.toTimeRemainingString(until: rotation.endTime))
      .scaledLimitedLine()
      .foregroundColor(.secondary)
      .fontIka(
        .ika2,
        size: Scoped.REMAINING_TIME_FONT_SIZE,
        relativeTo: .headline)
      .frame(
        maxWidth: rowWidth * Scoped.REMAINING_TIME_TEXT_MAX_WIDTH_RATIO,
        alignment: .trailing)
  }
}

// MARK: - BattleRotationCellSecondary

/// The secondary version of a cell component for the battle rotation
/// that takes all the space in a list unit.
struct BattleRotationCellSecondary: View {
  typealias Scoped = Constants.Styles.Rotation.Battle.Cell.Secondary

  let rotation: BattleRotation
  let rowWidth: CGFloat

  var body: some View {
    HStack {
      // MARK: Rule section

      VStack(spacing: Scoped.RULE_SECTION_SPACING) {
        // Rule img
        Image(rotation.rule.imgFilnMid)
          .antialiased(true)
          .resizable()
          .scaledToFit()
          .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
          .frame(maxWidth: rowWidth * Scoped.RULE_IMG_MAX_WIDTH)
          .padding(Scoped.RULE_IMG_PADDING)
          .background(Color.tertiarySystemGroupedBackground)
          .cornerRadius(Scoped.RULE_IMG_FRAME_CORNER_RADIUS)

        // Rule title
        Text(rotation.rule.name.localizedStringKey)
          .scaledLimitedLine()
          .fontIka(
            .ika2,
            size: Scoped.RULE_FONT_SIZE,
            relativeTo: .body)
          .frame(height: Scoped.RULE_TITLE_HEIGHT)
      }
      .frame(maxWidth: rowWidth * Scoped.RULE_SECTION_WIDTH_RATIO)
      .padding(.trailing, Scoped.RULE_SECTION_PADDING_TRAILING)

      // MARK: Stage Section

      HStack(
        alignment: .center,
        spacing: rowWidth * Scoped.STAGE_SECTION_SPACING_RATIO +
          Scoped.STAGE_SECTION_SPACING_ADJUSTMENT_CONSTANT)
      {
        BattleRotationStageCardSecondary(stage: rotation.stageA, altImageName: rotation.stageAltImageNameA)
        BattleRotationStageCardSecondary(stage: rotation.stageB, altImageName: rotation.stageAltImageNameB)
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
            rowWidth: geo.size.width)
        }
        Section {
          BattleRotationCellSecondary(
            rotation: IkaMockData.getBattleRotation(
              rule: .clamBlitz,
              rawStartTime: Date()),
            rowWidth: geo.size.width)
        }
      }
      .listStyle(InsetGroupedListStyle())
    }
  }
}
