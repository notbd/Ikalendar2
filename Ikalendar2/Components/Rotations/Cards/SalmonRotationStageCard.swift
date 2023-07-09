//
//  SalmonRotationStageCard.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationStageCardPrimary

/// A card component that displays the stage information of a salmon rotation.
/// - Parameters:
///   - swapLabels: if swap the position for title label and reward gear label
///                    (default: left -> gear, right -> title)
struct SalmonRotationStageCard: View {
  typealias Scoped = Constants.Styles.Rotation.Salmon.Card.Stage

  @EnvironmentObject var ikaTimer: IkaTimer

  var rotation: SalmonRotation
  let fontSize: CGFloat
  var swapLabels = false
  var width: CGFloat

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

  var overlay: some View {
    HStack(alignment: .bottom) {
      if swapLabels {
        stageTitleLabel
        Spacer()
      }
      HStack(alignment: .bottom) {
        if swapLabels {
          Spacer()
        }
        rewardGearImg
        if !swapLabels {
          Spacer()
        }
      }
      .frame(width: width * Scoped.APPAREL_SECTION_WIDTH_RATIO)
      if !swapLabels {
        Spacer()
        stageTitleLabel
      }
    }
    .padding(.bottom, Scoped.OVERLAY_PADDING)
    .padding(.horizontal, Scoped.OVERLAY_PADDING)
  }

  var stageTitleLabel: some View {
    StageTitleLabel(
      title: rotation.stage!.name,
      fontSize: fontSize)
  }

  var rewardGearImg: some View {
    var isShown: Bool {
      rotation.isCurrent(currentTime: ikaTimer.currentTime) && rotation.rewardApparel != nil
    }
    var content: some View {
      Image(rotation.rewardApparel?.imgFiln ?? "salmon")
        .resizable()
        .scaledToFit()
        .padding(Scoped.APPAREL_IMG_PADDING)
        .frame(width: width * Scoped.APPAREL_IMG_WIDTH_RATIO)
        .silhouetteFrame(
          cornerRadius: Scoped.APPAREL_SILHOUETTE_CORNER_RADIUS,
          colorScheme: .light)
    }
    return content
      .opacity(isShown ? 1 : 0)
  }
}

// struct SalmonRotationStageCard_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmonRotationStageCard()
//    }
// }
