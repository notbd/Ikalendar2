//
//  SalmonRotationStageCard.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationStageCard

/// A card component that displays the stage information of a salmon rotation.
struct SalmonRotationStageCard: View {
  typealias Scoped = Constants.Styles.Rotation.Salmon.Card.Stage

  @EnvironmentObject var ikaTimePublisher: IkaTimePublisher

  let rotation: SalmonRotation
  let rowWidth: CGFloat

  private var hasRewardApparel: Bool { rotation.rewardApparel != nil }
  private var isCurrent: Bool { rotation.isCurrent(currentTime: ikaTimePublisher.currentTime) }

  var body: some View {
    Image(rotation.stage!.imgFiln)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .cornerRadius(Scoped.STAGE_IMG_CORNER_RADIUS)
      .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
      .overlay(
        overlay,
        alignment: .bottom)
  }

  private var overlay: some View {
    var rewardApparelSection: some View {
      rewardApparelImg
        .hAlignment(isCurrent ? .trailing : .leading)
        .vAlignment(.bottom)
    }

    return
      HStack(alignment: .bottom) {
        if isCurrent {
          stageTitleLabel
          Spacer()
          rewardApparelSection
        }
        else {
          rewardApparelSection
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
      .resizable()
      .scaledToFit()
      .padding(Scoped.APPAREL_IMG_PADDING)
      .frame(width: rowWidth * Scoped.APPAREL_IMG_WIDTH_RATIO)
      .background(.ultraThinMaterial)
      .cornerRadius(Scoped.APPAREL_FRAME_CORNER_RADIUS)
      .opacity(isCurrent && hasRewardApparel ? 1 : 0)
  }
}

// MARK: - SalmonRotationStageCard_Previews

struct SalmonRotationStageCard_Previews: PreviewProvider {
  static var previews: some View {
    SalmonRotationStageCard(
      rotation: IkaMockData.getSalmonRotation(),
      rowWidth: 390)
  }
}
