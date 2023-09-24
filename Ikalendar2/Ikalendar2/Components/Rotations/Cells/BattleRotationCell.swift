//
//  BattleRotationCell.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationCell

@MainActor
struct BattleRotationCell: View {
  enum CellType {
    case primary
    case secondary
  }

  let type: CellType
  let rotation: BattleRotation
  let rowWidth: CGFloat

  @Namespace var ruleIcon
  @Namespace var ruleTitle
  @Namespace var stageA
  @Namespace var stageB

  var animationNamespaces: Constants.Namespace.Battle {
    .init(
      ruleIcon: ruleIcon,
      ruleTitle: ruleTitle,
      stageA: stageA,
      stageB: stageB)
  }

  var body: some View {
    switch type {
    case .primary:
      BattleRotationCellPrimary(
        rotation: rotation,
        rowWidth: rowWidth,
        animationNamespaces: animationNamespaces)
    case .secondary:
      BattleRotationCellSecondary(
        rotation: rotation,
        rowWidth: rowWidth,
        animationNamespaces: animationNamespaces)
    }
  }
}

// MARK: - BattleRotationCellPrimary

/// The primary version of a cell component for the battle rotation that takes
/// all the space in the list content.
@MainActor
struct BattleRotationCellPrimary: View {
  typealias Scoped = Constants.Style.Rotation.Battle.Cell.Primary

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let rotation: BattleRotation
  let rowWidth: CGFloat
  let animationNamespaces: Constants.Namespace.Battle?

  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  var body: some View {
    VStack(spacing: Scoped.CELL_SPACING_V) {
      HStack(alignment: .center) {
        ruleSection
        Spacer()
        remainingTimeSection
      }

      ProgressView(
        value: min(ikaTimePublisher.currentTime, rotation.endTime) - rotation.startTime,
        total: rotation.endTime - rotation.startTime)
        .padding(.bottom, Scoped.PROGRESS_BAR_PADDING_BOTTOM)
        .tint(rotation.mode.themeColor)

      // MARK: Stage Section

      HStack {
        battleStageCardA
        battleStageCardB
      }
    }
    .padding(.top, Scoped.CELL_PADDING_TOP)
    .padding(.bottom, Scoped.CELL_PADDING_BOTTOM)
  }

  // MARK: Rule Section

  private var ruleIcon: some View {
    Image(rotation.rule.imgFilnMid)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
      .layoutPriority(1)
      .ifLet(animationNamespaces) {
        $0.matchedGeometryEffect(
          id: rotation.id,
          in: $1.ruleIcon)
      }
  }

  private var ruleTitle: some View {
    IdealFontLayout(anchor: .leading) {
      // actual rule title
      Text(rotation.rule.name.localizedStringKey)
        .scaledLimitedLine()
        .ikaFont(
          .ika2,
          size: Scoped.RULE_TITLE_FONT_SIZE_MAX,
          relativeTo: Scoped.RULE_TITLE_TEXT_STYLE_RELATIVE_TO)

      // all other possible rule titles for the layout to compute ideal size
      ForEach(BattleRule.allCases) { rule in
        Text(rule.name.localizedStringKey)
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.RULE_TITLE_FONT_SIZE_MAX,
            relativeTo: Scoped.RULE_TITLE_TEXT_STYLE_RELATIVE_TO)
      }
    }
    .padding(.vertical, Scoped.RULE_TITLE_PADDING_V)
    .ifLet(animationNamespaces) {
      $0.matchedGeometryEffect(
        id: rotation.id,
        in: $1.ruleTitle)
    }
  }

  private var battleStageCardA: some View {
    BattleRotationStageCardPrimary(
      rotation: rotation,
      stageSelection: .stageA)
      .ifLet(animationNamespaces) {
        $0.matchedGeometryEffect(
          id: rotation.id,
          in: $1.stageA)
      }
  }

  private var battleStageCardB: some View {
    BattleRotationStageCardPrimary(
      rotation: rotation,
      stageSelection: .stageB)
      .ifLet(animationNamespaces) {
        $0.matchedGeometryEffect(
          id: rotation.id,
          in: $1.stageB)
      }
  }

  private var ruleSection: some View {
    HStack(
      alignment: .center,
      spacing: Scoped.RULE_SECTION_SPACING)
    {
      ruleIcon
      ruleTitle
    }
    .frame(
      width: rowWidth * Scoped.RULE_SECTION_WIDTH_RATIO,
      height: rowWidth * Scoped.RULE_SECTION_HEIGHT_RATIO,
      alignment: .leading)
    .hAlignment(.leading)
  }

  // MARK: Remaining Time Section

  private var remainingTimeSection: some View {
    Text(ikaTimePublisher.currentTime.toTimeRemainingStringKey(until: rotation.endTime))
      .contentTransition(.numericText(countsDown: true))
      .animation(.default, value: ikaTimePublisher.currentTime)
      .scaledLimitedLine()
      .foregroundStyle(Color.secondary)
      .ikaFont(
        .ika2,
        size: Scoped.REMAINING_TIME_FONT_SIZE,
        relativeTo: Scoped.REMAINING_TIME_TEXT_STYLE_RELATIVE_TO)
      .frame(
        width: rowWidth * Scoped.REMAINING_TIME_SECTION_WIDTH_RATIO,
        alignment: .trailing)
  }
}

// MARK: - BattleRotationCellSecondary

/// The secondary version of a cell component for the battle rotation
/// that takes all the space in a list unit.
@MainActor
struct BattleRotationCellSecondary: View {
  typealias Scoped = Constants.Style.Rotation.Battle.Cell.Secondary

  @EnvironmentObject private var ikaPreference: IkaPreference

  let rotation: BattleRotation
  let rowWidth: CGFloat
  let animationNamespaces: Constants.Namespace.Battle?

  var body: some View {
    HStack {
      // MARK: Rule section

      VStack(spacing: Scoped.RULE_SECTION_SPACING) {
        ruleIcon
        ruleTitle
      }
      .frame(width: rowWidth * Scoped.RULE_SECTION_WIDTH_RATIO)
      .padding(.trailing, Scoped.RULE_SECTION_PADDING_TRAILING)

      // MARK: Stage Section

      BattleSecondaryStagesLayout {
        battleStageCardA
        battleStageCardB
      }
    }
  }

  private var ruleIcon: some View {
    Image(rotation.rule.imgFilnMid)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
      .frame(height: rowWidth * Scoped.RULE_IMG_HEIGHT_RATIO)
      .padding(Scoped.RULE_IMG_PADDING)
      .background(Color.tertiarySystemGroupedBackground)
      .cornerRadius(Scoped.RULE_IMG_FRAME_CORNER_RADIUS)
      .ifLet(animationNamespaces) {
        $0.matchedGeometryEffect(
          id: rotation.id,
          in: $1.ruleIcon)
      }
  }

  private var ruleTitle: some View {
    IdealFontLayout(anchor: .center) {
      // actual rule title
      Text(rotation.rule.name.localizedStringKey)
        .scaledLimitedLine()
        .ikaFont(
          .ika2,
          size: Scoped.RULE_FONT_SIZE,
          relativeTo: .body)
      // all other possible rule titles for the layout to compute ideal size
      ForEach(BattleRule.allCases) { rule in
        Text(rule.name.localizedStringKey)
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.RULE_FONT_SIZE,
            relativeTo: .body)
      }
    }
    .frame(height: Scoped.RULE_TITLE_HEIGHT)
    .ifLet(animationNamespaces) {
      $0.matchedGeometryEffect(
        id: rotation.id,
        in: $1.ruleTitle)
    }
  }

  private var battleStageCardA: some View {
    BattleRotationStageCardSecondary(
      rotation: rotation,
      stageSelection: .stageA)
      .ifLet(animationNamespaces) {
        $0.matchedGeometryEffect(
          id: rotation.id,
          in: $1.stageA)
      }
  }

  private var battleStageCardB: some View {
    BattleRotationStageCardSecondary(
      rotation: rotation,
      stageSelection: .stageB)
      .ifLet(animationNamespaces) {
        $0.matchedGeometryEffect(
          id: rotation.id,
          in: $1.stageB)
      }
  }
}

// MARK: - BattleRotationCell_Previews

struct BattleRotationCell_Previews: PreviewProvider {
  static var previews: some View {
    @Namespace var ruleIcon
    @Namespace var ruleTitle
    @Namespace var stageA
    @Namespace var stageB

    GeometryReader { geo in
      List {
        Section {
          BattleRotationCellPrimary(
            rotation: IkaMockData.getBattleRotation(
              preferredMode: .gachi,
              preferredRule: .towerControl,
              rawStartTime: Date()),
            rowWidth: geo.size.width,
            animationNamespaces: nil)
        }
        Section {
          BattleRotationCellSecondary(
            rotation: IkaMockData.getBattleRotation(
              preferredMode: .gachi,
              preferredRule: .clamBlitz,
              rawStartTime: Date()),
            rowWidth: geo.size.width,
            animationNamespaces: nil)
        }
      }
      .listStyle(InsetGroupedListStyle())
    }
  }
}
