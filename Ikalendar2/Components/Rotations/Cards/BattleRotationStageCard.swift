//
//  BattleRotationStageCard.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationStageCardPrimary

/// The primary version of a card component that displays
/// the stage information of a battle rotation.
struct BattleRotationStageCardPrimary: View {
  typealias Scoped = Constants.Styles.Rotation.Battle.Card.Primary

  @EnvironmentObject private var ikaPreference: IkaPreference

  let stage: BattleStage
  let altImageName: String

  private var stageImageName: String { ikaPreference.ifUseAltStageImages
    ? altImageName
    : stage.imgFilnLarge }

  var body: some View {
    Image(stageImageName)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .cornerRadius(Scoped.IMG_CORNER_RADIUS)
      .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
      .overlay(
        StageTitleLabel(
          title: stage.name,
          fontSize: Scoped.LABEL_FONT_SIZE,
          relTextStyle: .body)
          .padding(.leading, Scoped.LABEL_PADDING_LEADING)
          .padding(.bottom, Scoped.LABEL_PADDING_BOTTOMTRAILING)
          .padding(.trailing, Scoped.LABEL_PADDING_BOTTOMTRAILING),
        alignment: .bottomTrailing)
  }
}

// MARK: - BattleRotationStageCardSecondary

/// The secondary version of a card component that displays
/// the stage information of a battle rotation.
struct BattleRotationStageCardSecondary: View {
  typealias Scoped = Constants.Styles.Rotation.Battle.Card.Secondary

  @EnvironmentObject private var ikaPreference: IkaPreference

  let stage: BattleStage
  let altImageName: String

  private var stageImageName: String { ikaPreference.ifUseAltStageImages
    ? altImageName
    : stage.imgFilnLarge }

  var body: some View {
    VStack(
      alignment: .trailing,
      spacing: Scoped.V_SPACING)
    {
      Image(stageImageName)
        .antialiased(true)
        .resizable()
        .scaledToFit()
        .cornerRadius(Scoped.IMG_CORNER_RADIUS)
        .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
        .offset(y: Scoped.STAGE_IMG_OFFSET_Y)

      Text(stage.name.localizedStringKey)
        .scaledLimitedLine()
        .fontIka(
          .ika2,
          size: Scoped.FONT_SIZE,
          relativeTo: .body)
    }
  }
}

// MARK: - BattleRotationStageCard_Previews

struct BattleRotationStageCard_Previews: PreviewProvider {
  static var previews: some View {
    BattleRotationStageCardPrimary(stage: .theReef, altImageName: "The_Reef_Alt_0")
      .previewLayout(.fixed(width: 320, height: 200))
    BattleRotationStageCardSecondary(stage: .humpbackPumpTrack, altImageName: "Humpback_Pump_Track_Alt_0")
      .previewLayout(.fixed(width: 300, height: 240))
  }
}
