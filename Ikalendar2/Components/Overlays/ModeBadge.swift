//
//  ModeBadge.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ModeBadge

/// The small glass badge at the trailing end of the compact-width nav bar that the mode stamp
/// docks into while the list scrolls up. It shows the stamp's image upright, like a toolbar icon.
struct ModeBadge: View {
  typealias Scoped = Constants.Style.Overlay.ModeIcon

  let flatMode: FlatMode

  var body: some View {
    Image(decorative: imageName)
      .ikaFitted()
      .frame(
        width: imageSize,
        height: imageSize)
      .offset(y: imageOffsetY)
      .frame(
        width: Scoped.badgeSize,
        height: Scoped.badgeSize)
      // Mr. Grizz's antenna reaches past the circle once his body is centered.
      .clipShape(.circle)
      // Not interactive: the badge is decoration, so it must not react to touches.
      .adaptiveGlassEffect(isInteractive: false, in: .circle)
      // The navigation title already names the mode.
      .accessibilityHidden(true)
  }

  private var imageName: String {
    flatMode.battleMode?.imageNameLarge ?? Scoped.iconImageNameSalmon
  }

  /// Sized so the visible artwork looks the same size in every mode: its area matches, then the
  /// regular image is taken down and Mr. Grizz up a step by eye, since the regular image's bold
  /// white arrow reads larger and the dark statue reads smaller than the ranked and league shields.
  private var imageSize: CGFloat {
    switch flatMode {
      case .regular:
        Scoped.badgeImageSizeRegular
      case .gachi,
           .league:
        Scoped.badgeImageSize
      case .salmon:
        Scoped.badgeImageSizeSalmon
    }
  }

  /// Mr. Grizz sits in the lower part of his canvas (under his antenna), so he is lifted to put his
  /// body in the middle of the badge; the other images are centered in theirs.
  private var imageOffsetY: CGFloat {
    flatMode == .salmon ? Scoped.badgeImageOffsetYSalmon : 0
  }
}

#Preview {
  ModeBadge(flatMode: .gachi)
}
