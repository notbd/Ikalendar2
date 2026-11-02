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
      .frame(
        width: Scoped.badgeSize,
        height: Scoped.badgeSize)
      // Not interactive: the badge is decoration, so it must not react to touches.
      .adaptiveGlassEffect(isInteractive: false, in: .circle)
      // The navigation title already names the mode.
      .accessibilityHidden(true)
  }

  private var imageName: String {
    flatMode.battleMode?.imageNameLarge ?? Scoped.iconImageNameSalmon
  }

  /// Sized by eye so the four images look the same size: the regular artwork leaves more of its
  /// canvas transparent (about 44% covered against about 62% for the ranked and league shields),
  /// and Mr. Grizz is a dark, low-contrast statue sitting low in his canvas.
  private var imageSize: CGFloat {
    switch flatMode {
      case .regular,
           .salmon:
        Scoped.badgeImageSizeSparse
      case .gachi,
           .league:
        Scoped.badgeImageSize
    }
  }
}

#Preview {
  ModeBadge(flatMode: .gachi)
}
