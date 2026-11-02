//
//  SalmonRotationStageCard.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationStageCard

/// A card component that displays the stage information of a salmon rotation.
struct SalmonRotationStageCard: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Card.Stage

  @Environment(IkaPreference.self) private var ikaPreference
  @Environment(IkaClock.self) private var ikaClock

  @State private var cardWidth: CGFloat = Scoped.initialCardWidth

  let rotation: SalmonRotation

  private var hasRewardApparel: Bool { rotation.rewardApparel != nil }
  private var shouldOverrideWithLarge: Bool { cardWidth >= Scoped.largeImageMinWidth }
  private var isRewardApparelVisible: Bool { rotation.isCurrent(ikaClock.currentTime) && hasRewardApparel }

  private var stageImageName: String {
    // Caller (SalmonRotationCell) only renders this card when rotation.stage != nil.
    guard let stage = rotation.stage else {
      assertionFailure("SalmonRotationStageCard requires rotation.stage != nil (guarded by caller)")
      return ""
    }

    return ikaPreference.shouldUseAltStageImages
      ? shouldOverrideWithLarge
        ? rotation.stageAltImageNameLarge ?? stage.imageNameLarge
        : rotation.stageAltImageName ?? stage.imageName
      : shouldOverrideWithLarge
        ? stage.imageNameLarge
        : stage.imageName
  }

  var body: some View {
    Image(decorative: stageImageName)
      .ikaFitted()
      .clipShape(.rect(cornerRadius: Scoped.stageImageCornerRadius))
      .adaptiveGlassEffect(in: .rect(cornerRadius: Scoped.stageImageCornerRadius))
      .shadow(radius: Constants.Style.Global.shadowRadius)
      .overlay(
        overlay,
        alignment: .bottom)
      .animation(
        .snappy,
        value: ikaPreference.shouldUseAltStageImages)
      .onGeometryChange(for: CGFloat.self) { geo in
        geo.size.width
      } action: { newWidth in
        cardWidth = newWidth
      }
  }

  private var overlay: some View {
    HStack(alignment: .bottom) {
      if rotation.isCurrent(ikaClock.currentTime) {
        stageTitleLabel
        Spacer()
        rewardApparelImg
      }
      else {
        rewardApparelImg
        Spacer()
        stageTitleLabel
      }
    }
    .padding(Scoped.overlayPadding)
  }

  private var stageTitleLabel: some View {
    StageTitleLabel(
      title: rotation.stage?.name ?? "",
      fontSize: Scoped.labelFontSize,
      relTextStyle: .body)
  }

  private var rewardApparelImg: some View {
    Image(rotation.rewardApparel?.imageName ?? "salmon")
      .ikaFitted()
      .padding(Scoped.apparelImagePadding)
      .frame(width: cardWidth * Scoped.apparelImageWidthRatio)
      .glassEffect(
        .clear.interactive(),
        in: .rect(cornerRadius: Scoped.apparelFrameCornerRadius))
      .opacity(isRewardApparelVisible ? 1 : 0)
      .accessibilityLabel(Text((rotation.rewardApparel?.name ?? "").localizedStringKey))
      .accessibilityHidden(!isRewardApparelVisible)
  }
}

#Preview {
  SalmonRotationStageCard(
    rotation: IkaMockData.makeSalmonRotation(rawStartTime: Date()))
    .frame(width: 312)
    .ikaPreviewEnvironment()
}
