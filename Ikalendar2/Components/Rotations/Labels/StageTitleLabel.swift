//
//  StageTitleLabel.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - StageTitleLabel

/// A label overlay displaying the title of the stage.
struct StageTitleLabel: View {
  typealias Scoped = Constants.Styles.Rotation.Label

  let title: String
  let fontSize: CGFloat
  let relTextStyle: Font.TextStyle

  var body: some View {
    Text(title.localizedStringKey())
      .scaledLimitedLine()
      .fontIka(
        .ika2,
        size: fontSize,
        relativeTo: relTextStyle)
      .padding(.horizontal, Scoped.TEXT_PADDING_HORIZONTAL)
      .background(.ultraThinMaterial)
      .cornerRadius(Scoped.BACKGROUND_CORNER_RADIUS)
  }
}

// MARK: - StageTitleLabel_Previews

struct StageTitleLabel_Previews: PreviewProvider {
  static var previews: some View {
    StageTitleLabel(
      title: BattleStage.humpbackPumpTrack.name,
      fontSize: 12,
      relTextStyle: .body)
  }
}
