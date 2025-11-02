//
//  SalmonRotationStageCard.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationStageCard

/// A card component that displays the stage information of a salmon rotation.
@MainActor
struct SalmonRotationStageCard: View {
  typealias Scoped = Constants.Style.Rotation.Salmon.Card.Stage

  @EnvironmentObject private var ikaPreference: IkaPreference
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  @State private var cardWidth: CGFloat = 150

  @Environment(\.colorScheme) private var colorScheme
  private var colorSchemeAwareGlass: Glass {
    colorScheme == .dark ? .clear : .regular
  }

  let rotation: SalmonRotation

  private var hasRewardApparel: Bool { rotation.rewardApparel != nil }
  private var shouldOverrideWithLarge: Bool { cardWidth >= 200 }

  private var stageImageName: String { ikaPreference.shouldUseAltStageImages
    ? shouldOverrideWithLarge
      ? rotation.stageAltImageNameLarge!
      : rotation.stageAltImageName!
    : shouldOverrideWithLarge
      ? rotation.stage!.imgFilnLarge
      : rotation.stage!.imgFiln }

  var body: some View {
    Image(stageImageName)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .cornerRadius(Scoped.STAGE_IMG_CORNER_RADIUS)
      .glassEffect(
        colorSchemeAwareGlass.interactive(),
        in: .rect(cornerRadius: Scoped.STAGE_IMG_CORNER_RADIUS))
      .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
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
      if rotation.isCurrent(ikaTimePublisher.currentTime) {
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
    .padding(Scoped.OVERLAY_PADDING)
  }

  private var stageTitleLabel: some View {
    StageTitleLabel(
      title: rotation.stage!.name,
      fontSize: Scoped.LABEL_FONT_SIZE,
      relTextStyle: .body)
  }

  private var rewardApparelImg: some View {
    Image(rotation.rewardApparel?.imgFiln ?? "salmon")
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .padding(Scoped.APPAREL_IMG_PADDING)
      .frame(width: cardWidth * Scoped.APPAREL_IMG_WIDTH_RATIO)
      .glassEffect(
        .clear.interactive(),
        in: .rect(cornerRadius: Scoped.APPAREL_FRAME_CORNER_RADIUS))
      .opacity(rotation.isCurrent(ikaTimePublisher.currentTime) && hasRewardApparel ? 1 : 0)
  }
}

// MARK: - SalmonRotationStageCard_Previews

struct SalmonRotationStageCard_Previews: PreviewProvider {
  static var previews: some View {
    SalmonRotationStageCard(
      rotation: IkaMockData.getSalmonRotation())
      .frame(width: 312)
  }
}
