//
//  StageTitleLabel.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import IkalendarKit
import SwiftUI

// MARK: - StageTitleLabel

/// A label overlay displaying the title of the stage.
struct StageTitleLabel: View {
  typealias Scoped = Constants.Style.Rotation.Label

  let title: String
  let fontSize: CGFloat
  let relTextStyle: Font.TextStyle

  var body: some View {
    Text(title.localizedStringKey)
      .scaledLimitedLine()
      .ikaFont(
        .ika2,
        size: fontSize,
        relativeTo: relTextStyle)
      .padding(.horizontal, Scoped.textPaddingH)
      .padding(.vertical, Scoped.textPaddingV)
      .glassEffect(
        .regular.interactive(),
        in: .rect(cornerRadius: Scoped.clipShapeCornerRadius))
  }
}

#Preview {
  VStack(spacing: 8) {
    // longest and shortest stage names: exercises the scaled-line-limit behavior
    StageTitleLabel(
      title: BattleStage.humpbackPumpTrack.name,
      fontSize: 12,
      relTextStyle: .body)
    StageTitleLabel(
      title: BattleStage.theReef.name,
      fontSize: 12,
      relTextStyle: .body)
  }
}
