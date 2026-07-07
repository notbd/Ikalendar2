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

  @State private var cardWidth: CGFloat = 150

  let rotation: SalmonRotation

  private var hasRewardApparel: Bool { rotation.rewardApparel != nil }
  private var shouldOverrideWithLarge: Bool { cardWidth >= 200 }

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
    Image(stageImageName)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .clipShape(.rect(cornerRadius: Scoped.stageImgCornerRadius))
      .adaptiveGlassEffect(in: .rect(cornerRadius: Scoped.stageImgCornerRadius))
      .shadow(radius: Constants.Style.Global.shadowRadius)
      .overlay(
        overlay,
        alignment: .bottom)
      .animation(
        .snappy,
        value: ikaPreference.shouldUseAltStageImages)
      .background {
        GeometryReader { geo in
          Color.clear
            .onChange(of: geo.size, initial: true) { _, newVal in
              cardWidth = newVal.width
            }
        }
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
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .padding(Scoped.apparelImgPadding)
      .frame(width: cardWidth * Scoped.apparelImgWidthRatio)
      .glassEffect(
        .clear.interactive(),
        in: .rect(cornerRadius: Scoped.apparelFrameCornerRadius))
      .opacity(rotation.isCurrent(ikaClock.currentTime) && hasRewardApparel ? 1 : 0)
  }
}

#Preview {
  SalmonRotationStageCard(
    rotation: IkaMockData.getSalmonRotation(rawStartTime: Date()))
    .frame(width: 312)
    .ikaPreviewEnvironment()
}
