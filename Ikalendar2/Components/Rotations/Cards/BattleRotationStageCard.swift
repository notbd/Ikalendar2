//
//  BattleRotationStageCard.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationStageCardPrimary

/// The primary version of a card component that displays
/// the stage information of a battle rotation.
struct BattleRotationStageCardPrimary: View {
  typealias Scoped = Constants.Style.Rotation.Battle.Card.Primary

  @Environment(IkaPreference.self) private var ikaPreference

  let rotation: BattleRotation
  let stageSelection: BattleStageSelection

  private var stage: BattleStage {
    stageSelection == .stageA ? rotation.stageA : rotation.stageB
  }

  private var stageImageName: String {
    rotation.stageImageName(
      for: stageSelection,
      shouldUseAltImage: ikaPreference.shouldUseAltStageImages)
  }

  var body: some View {
    Image(decorative: stageImageName)
      .ikaFitted()
      .clipShape(.rect(cornerRadius: Scoped.imageCornerRadius))
      .adaptiveGlassEffect(in: .rect(cornerRadius: Scoped.imageCornerRadius))
      .shadow(radius: Constants.Style.Global.shadowRadius)
      .overlay(
        StageTitleLabel(
          title: stage.name,
          fontSize: Scoped.labelFontSize,
          relTextStyle: .body)
          .padding(.leading, Scoped.labelPaddingLeading)
          .padding([.bottom, .trailing], Scoped.labelPaddingBottomTrailing),
        alignment: .bottomTrailing)
      .animation(
        .snappy,
        value: ikaPreference.shouldUseAltStageImages)
  }
}

// MARK: - BattleRotationStageCardSecondary

/// The secondary version of a card component that displays
/// the stage information of a battle rotation.
struct BattleRotationStageCardSecondary: View {
  typealias Scoped = Constants.Style.Rotation.Battle.Card.Secondary

  @Environment(IkaPreference.self) private var ikaPreference

  let rotation: BattleRotation
  let stageSelection: BattleStageSelection

  private var stage: BattleStage {
    stageSelection == .stageA ? rotation.stageA : rotation.stageB
  }

  private var stageImageName: String {
    rotation.stageImageName(
      for: stageSelection,
      shouldUseAltImage: ikaPreference.shouldUseAltStageImages)
  }

  var body: some View {
    VStack(
      alignment: .trailing,
      spacing: Scoped.spacingV)
    {
      Image(decorative: stageImageName)
        .ikaFitted()
        .clipShape(.rect(cornerRadius: Scoped.imageCornerRadius))
        .glassEffect(
          .clear.interactive(),
          in: .rect(cornerRadius: Scoped.imageCornerRadius))
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .layoutPriority(1)

      Text(stage.name.localizedStringKey)
        .scaledLimitedLine()
        .ikaFont(
          .ika2,
          size: Scoped.fontSize,
          relativeTo: .body)
    }
    .animation(
      .snappy,
      value: ikaPreference.shouldUseAltStageImages)
  }
}

// MARK: - BattleStageSelection

/// Which of a battle rotation's two stages a card should show.
enum BattleStageSelection {
  case stageA
  case stageB
}

// MARK: - BattleRotation

extension BattleRotation {
  /// The image name of the selected stage, honoring the alt stage images preference.
  fileprivate func stageImageName(for stageSelection: BattleStageSelection, shouldUseAltImage: Bool) -> String {
    switch (shouldUseAltImage, stageSelection) {
      case (true, .stageA):
        stageAAltImageName
      case (true, .stageB):
        stageBAltImageName
      case (false, .stageA):
        stageA.imageName
      case (false, .stageB):
        stageB.imageName
    }
  }
}

// MARK: - Previews

#Preview("Primary / Stage A", traits: .fixedLayout(width: 320, height: 200)) {
  BattleRotationStageCardPrimary(
    rotation: IkaMockData.makeBattleRotation(),
    stageSelection: .stageA)
    .ikaPreviewEnvironment()
}

#Preview("Secondary / Stage B", traits: .fixedLayout(width: 300, height: 240)) {
  BattleRotationStageCardSecondary(
    rotation: IkaMockData.makeBattleRotation(),
    stageSelection: .stageB)
    .ikaPreviewEnvironment()
}
