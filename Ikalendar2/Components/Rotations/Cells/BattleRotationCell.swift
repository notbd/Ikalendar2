//
//  BattleRotationCell.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import IkalendarKit
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
struct BattleRotationCellPrimary: View {
  typealias Scoped = Constants.Style.Rotation.Battle.Cell.Primary

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @Environment(IkaClock.self) private var ikaClock

  let rotation: BattleRotation
  let rowWidth: CGFloat
  let animationNamespaces: Constants.Namespace.Battle?

  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  var body: some View {
    VStack(spacing: Scoped.cellSpacingV) {
      HStack(alignment: .center) {
        ruleSection
        Spacer()
        remainingTimeSection
      }

      ProgressView(
        value: min(ikaClock.currentTime, rotation.endTime) - rotation.startTime,
        total: rotation.endTime - rotation.startTime)
        .padding(.bottom, Scoped.progressBarPaddingBottom)
        .tint(rotation.mode.themeColor)

      // MARK: Stage Section

      HStack(spacing: Scoped.stagesSpacingH) {
        battleStageCardA
        battleStageCardB
      }
    }
    .padding(.top, Scoped.cellPaddingTop)
    .padding(.bottom, Scoped.cellPaddingBottom)
  }

  // MARK: Rule Section

  private var ruleIcon: some View {
    Image(rotation.rule.imageNameMid)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .shadow(radius: Constants.Style.Global.shadowRadius)
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
          size: Scoped.ruleTitleFontSizeMax,
          relativeTo: Scoped.ruleTitleTextStyleRelativeTo)

      // all other possible rule titles for the layout to compute ideal size
      ForEach(BattleRule.allCases) { rule in
        Text(rule.name.localizedStringKey)
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.ruleTitleFontSizeMax,
            relativeTo: Scoped.ruleTitleTextStyleRelativeTo)
      }
    }
    .padding(.vertical, Scoped.ruleTitlePaddingV)
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
      spacing: Scoped.ruleSectionSpacing)
    {
      ruleIcon
      ruleTitle
    }
    .frame(
      width: rowWidth * Scoped.ruleSectionWidthRatio,
      height: rowWidth * Scoped.ruleSectionHeightRatio,
      alignment: .leading)
    .hAlignment(.leading)
  }

  // MARK: Remaining Time Section

  private var remainingTimeSection: some View {
    Text(ikaClock.currentTime.toTimeRemainingStringKey(until: rotation.endTime))
      .contentTransition(.numericText(countsDown: true))
      .animation(.snappy, value: ikaClock.currentTime)
      .scaledLimitedLine()
      .foregroundStyle(Color.secondary)
      .ikaFont(
        .ika2,
        size: Scoped.remainingTimeFontSize,
        relativeTo: Scoped.remainingTimeTextStyleRelativeTo)
      .frame(
        width: rowWidth * Scoped.remainingTimeSectionWidthRatio,
        alignment: .trailing)
  }
}

// MARK: - BattleRotationCellSecondary

/// The secondary version of a cell component for the battle rotation
/// that takes all the space in a list unit.
struct BattleRotationCellSecondary: View {
  typealias Scoped = Constants.Style.Rotation.Battle.Cell.Secondary

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(\.colorScheme) private var colorScheme
  private var colorSchemeAwareGlass: Glass {
    colorScheme == .dark ? .clear : .regular
  }

  @Environment(IkaPreference.self) private var ikaPreference

  let rotation: BattleRotation
  let rowWidth: CGFloat
  let animationNamespaces: Constants.Namespace.Battle?

  var body: some View {
    HStack {
      // MARK: Rule section

      VStack(spacing: Scoped.ruleSectionSpacing) {
        ruleIcon
        ruleTitle
      }
      .frame(width: rowWidth * Scoped.ruleSectionWidthRatio)
      .padding(.trailing, Scoped.ruleSectionPaddingTrailing)

      // MARK: Stage Section

      BattleSecondaryStagesLayout {
        battleStageCardA
        battleStageCardB
      }
    }
  }

  private var ruleIcon: some View {
    Image(rotation.rule.imageNameMid)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .shadow(radius: Constants.Style.Global.shadowRadius)
      .frame(height: rowWidth * Scoped.ruleImgHeightRatio)
      .padding(Scoped.ruleImgPadding)
      .glassEffect(
        colorSchemeAwareGlass.interactive(),
        in: .rect(cornerRadius: Scoped.ruleImgFrameCornerRadius))
      .ifLet(animationNamespaces) {
        $0.matchedGeometryEffect(
          id: rotation.id,
          in: $1.ruleIcon)
      }
  }

  private var ruleTitle: some View {
    // actual rule title
    Text(rotation.rule.name.localizedStringKey)
      .scaledLimitedLine()
      .ikaFont(
        .ika2,
        size: Scoped.ruleFontSize,
        relativeTo: .body)
      .if(!isHorizontalCompact) { wrapInIdealFontLayout($0) }
      .frame(height: Scoped.ruleTitleHeight)
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

  private func wrapInIdealFontLayout(_ content: some View) -> some View {
    IdealFontLayout(anchor: .center) {
      // actual rule title
      content

      // all other possible rule titles for the layout to compute ideal size
      ForEach(BattleRule.allCases) { rule in
        Text(rule.name.localizedStringKey)
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.ruleFontSize,
            relativeTo: .body)
      }
    }
  }
}

#Preview {
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
    .listStyle(.insetGrouped)
  }
}
