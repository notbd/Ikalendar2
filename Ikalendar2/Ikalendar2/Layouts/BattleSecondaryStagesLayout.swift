//
//  BattleSecondaryStagesLayout.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// `BattleSecondaryStagesLayout` is a custom layout designed to position two stage cards
/// horizontally within a parent view. It aims to horizontally align the images of the two stage
/// cards while accounting for variable text height in the titles.
///
/// It lays out the two stage cards horizontally with equal width and propose the height of the
/// minimal ideal height of the two stage cards to its parent view. The two cards might have
/// different ideal heights due to the potential scaling of the title.
/// Since the image is set to have higher layout priority than the title, having same width
/// for the two stage cards will ensure their images aligns correctly as well.
///
/// - Precondition:
///   - The proposed width must already be set.
///   - Must have exactly two subviews: one for the stage and one for the weapons.
///
struct BattleSecondaryStagesLayout: Layout {

  // MARK: Internal

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ())
    -> CGSize
  {
    guard proposal.width != nil else { return .zero }
    guard subviews.count == 2 else { return .zero }

    let hSpacings = getHSpacings(subviews: subviews)
    let subviewProposal = ProposedViewSize(
      width: (proposal.width! - hSpacings[0]) * (1 / 2),
      height: proposal.height)
    let minIdealSize = getMinIdealSize(subviews: subviews, proposal: subviewProposal)

    return CGSize(
      width: proposal.width!,
      height: minIdealSize.height)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ())
  {
    guard proposal.width != nil else { return }
    guard subviews.count == 2 else { return }

    let hSpacings = getHSpacings(subviews: subviews)
    let subviewProposal = ProposedViewSize(
      width: (proposal.width! - hSpacings[0]) * (1 / 2),
      height: proposal.height)
    let minIdealSize = getMinIdealSize(subviews: subviews, proposal: subviewProposal)

    let stageWidth = minIdealSize.width
    let stageHeight = minIdealSize.height

    let stageACenterX = bounds.minX + stageWidth * (1 / 2)
    let stageACenterY = bounds.midY

    let stageBCenterX = bounds.maxX - stageWidth * (1 / 2)
    let stageBCenterY = bounds.midY

    let stageSizeProposal = ProposedViewSize(
      width: stageWidth,
      height: stageHeight)

    // placing stage card
    subviews[0].place(
      at: CGPoint(
        x: stageACenterX,
        y: stageACenterY),
      anchor: .center,
      proposal: stageSizeProposal)

    // placing weapon card
    subviews[1].place(
      at: CGPoint(
        x: stageBCenterX,
        y: stageBCenterY),
      anchor: .center,
      proposal: stageSizeProposal)
  }

  // MARK: Private

  private func getHSpacings(subviews: Subviews) -> [CGFloat] {
    subviews.indices.map { index in
      guard index < subviews.count - 1 else { return 0 }
      return
        subviews[index].spacing
          .distance(
            to: subviews[index + 1].spacing,
            along: .horizontal)
    }
  }

  private func getMinIdealSize(subviews: Subviews, proposal: ProposedViewSize) -> CGSize {
    let subviewSizes = subviews.map { $0.sizeThatFits(proposal) }
    let minIdealSize: CGSize = subviewSizes.reduce(
      CGSize(
        width: CGFloat.infinity,
        height: CGFloat.infinity))
    { currentMin, nextSize in
      CGSize(
        width: min(currentMin.width, nextSize.width),
        height: min(currentMin.height, nextSize.height))
    }
    return minIdealSize
  }

}
