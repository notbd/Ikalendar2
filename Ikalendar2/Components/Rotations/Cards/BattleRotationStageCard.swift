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

  @EnvironmentObject private var ikaPreference: IkaPreference

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
        rotation.stageA.imgFiln
      case (false, .stageB):
        rotation.stageB.imgFiln
    }
  }

  var body: some View {
    Image(stageImageName)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .cornerRadius(Scoped.IMG_CORNER_RADIUS)
      .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
      .overlay(
        StageTitleLabel(
          title: stage.name,
          fontSize: Scoped.LABEL_FONT_SIZE,
          relTextStyle: .body)
          .padding(.leading, Scoped.LABEL_PADDING_LEADING)
          .padding([.bottom, .trailing], Scoped.LABEL_PADDING_BOTTOMTRAILING),
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

  @EnvironmentObject private var ikaPreference: IkaPreference

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
        rotation.stageA.imgFiln
      case (false, .stageB):
        rotation.stageB.imgFiln
    }
  }

  var body: some View {
    VStack(
      alignment: .trailing,
      spacing: Scoped.SPACING_V)
    {
      Image(stageImageName)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .cornerRadius(Scoped.IMG_CORNER_RADIUS)
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .alignmentGuide(.battleStagesImageAlignment) { $0[.bottom] }
        .layoutPriority(1)

      Text(stage.name.localizedStringKey)
        .scaledLimitedLine()
        .ikaFont(
          .ika2,
          size: Scoped.FONT_SIZE,
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

struct BattleRotationStageCard_Previews: PreviewProvider {
  static var previews: some View {
    let rotation = IkaMockData.getBattleRotation()
    return
      Group {
        BattleRotationStageCardPrimary(
          rotation: rotation,
          stageSelection: .stageA)
          .previewLayout(.fixed(width: 320, height: 200))
        BattleRotationStageCardPrimary(
          rotation: rotation,
          stageSelection: .stageB)
          .previewLayout(.fixed(width: 300, height: 240))
      }
  }
}
