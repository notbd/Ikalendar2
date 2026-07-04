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

  @Environment(\.colorScheme) private var colorScheme
  private var colorSchemeAwareGlass: Glass {
    colorScheme == .dark ? .clear : .regular
  }

  let rotation: BattleRotation
  let stageSelection: BattleStageSelection

  private var stage: BattleStage {
    stageSelection == .stageA ? rotation.stageA : rotation.stageB
  }

  private var stageImageName: String {
    switch (ikaPreference.shouldUseAltStageImages, stageSelection) {
      case (true, .stageA):
        rotation.stageAAltImageName
      case (true, .stageB):
        rotation.stageBAltImageName
      case (false, .stageA):
        rotation.stageA.imageName
      case (false, .stageB):
        rotation.stageB.imageName
    }
  }

  var body: some View {
    Image(stageImageName)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .clipShape(.rect(cornerRadius: Scoped.imgCornerRadius))
      .glassEffect(
        colorSchemeAwareGlass.interactive(),
        in: .rect(cornerRadius: Scoped.imgCornerRadius))
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
    switch (ikaPreference.shouldUseAltStageImages, stageSelection) {
      case (true, .stageA):
        rotation.stageAAltImageName
      case (true, .stageB):
        rotation.stageBAltImageName
      case (false, .stageA):
        rotation.stageA.imageName
      case (false, .stageB):
        rotation.stageB.imageName
    }
  }

  var body: some View {
    VStack(
      alignment: .trailing,
      spacing: Scoped.spacingV)
    {
      Image(stageImageName)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .clipShape(.rect(cornerRadius: Scoped.imgCornerRadius))
        .glassEffect(
          .clear.interactive(),
          in: .rect(cornerRadius: Scoped.imgCornerRadius))
        .shadow(radius: Constants.Style.Global.shadowRadius)
        .alignmentGuide(.battleStagesImageAlignment) { $0[.bottom] }
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

enum BattleStageSelection {
  case stageA
  case stageB
}

// MARK: - BattleRotationStageCard_Previews

#Preview("Stage A", traits: .fixedLayout(width: 320, height: 200)) {
  BattleRotationStageCardPrimary(
    rotation: IkaMockData.getBattleRotation(),
    stageSelection: .stageA)
}

#Preview("Stage B", traits: .fixedLayout(width: 300, height: 240)) {
  BattleRotationStageCardPrimary(
    rotation: IkaMockData.getBattleRotation(),
    stageSelection: .stageB)
}
