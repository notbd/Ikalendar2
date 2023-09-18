//
//  BattlePrimaryRuleTitleTextLayout.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// `BattlePrimaryRuleTitleTextLayout` is a custom layout designed to scale a battle
/// title text correctly within a parent view in order to have a consistent look across
/// all possible battle rules.
///
/// The parent view should have a fixed width and height. Since the title text is scalable,
/// the battle rule with longer names might end up with smaller font than others. This layout
/// tries to account for all possible rule titles, and restrict itself to have a height of
/// the minimum of all possible text heights.
///
/// - Precondition:
///   - The proposed width and height must already be set.
///   - The first subview is the actual text view that is going to be displayed. The rest of
///     subviews are all possible rule title texts, which are used to compute the ideal size
///     and will not be displayed.
///
struct BattlePrimaryRuleTitleTextLayout: Layout {

  // MARK: Internal

  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ())
    -> CGSize
  {
    let minIdealSize = getMinIdealSize(subviews: subviews, proposal: proposal)
    let maxIdealSize = getMaxIdealSize(subviews: subviews, proposal: proposal)

    return CGSize(
      width: maxIdealSize.width,
      height: minIdealSize.height)
  }

  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache _: inout ())
  {
    let minIdealSize = getMinIdealSize(subviews: subviews, proposal: proposal)
    let maxIdealSize = getMaxIdealSize(subviews: subviews, proposal: proposal)

    let textWidth = maxIdealSize.width
    let textHeight = minIdealSize.height

    let textMinX = bounds.minX
    let textMidY = bounds.midY

    let textSizeProposal = ProposedViewSize(
      width: textWidth,
      height: textHeight)

    for index in subviews.indices {
      if index == 0 {
        // placing title text
        subviews[index].place(
          at: CGPoint(
            x: textMinX,
            y: textMidY),
          anchor: .leading,
          proposal: textSizeProposal)
      }
      else {
        // skip all others
        subviews[index].place(
          at: CGPoint(
            x: bounds.minX,
            y: bounds.minY),
          anchor: .center,
          proposal: ProposedViewSize(width: 0, height: 0))
      }
    }
  }

  // MARK: Private

  private func getMinIdealSize(
    subviews: Subviews,
    proposal: ProposedViewSize)
    -> CGSize
  {
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

  private func getMaxIdealSize(
    subviews: Subviews,
    proposal: ProposedViewSize)
    -> CGSize
  {
    let subviewSizes = subviews.map { $0.sizeThatFits(proposal) }
    let maxIdealSize: CGSize = subviewSizes.reduce(.zero)
    { currentMax, nextSize in
      CGSize(
        width: max(currentMax.width, nextSize.width),
        height: max(currentMax.height, nextSize.height))
    }
    return maxIdealSize
  }

}
