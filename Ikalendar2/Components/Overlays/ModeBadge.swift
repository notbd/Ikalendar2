//
//  ModeBadge.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ModeBadge

/// The small glass badge at the trailing end of the iPhone nav bar that the mode stamp docks into
/// while the list scrolls up. It shows the stamp's image, tilted like the stamp.
struct ModeBadge: View {
  typealias Scoped = Constants.Style.Overlay.ModeIcon

  let flatMode: FlatMode

  var body: some View {
    Image(decorative: imageName)
      .ikaFitted()
      .rotationEffect(.degrees(Scoped.rotation2dDegrees))
      .frame(
        width: Scoped.badgeImageSize,
        height: Scoped.badgeImageSize)
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
}

#Preview {
  ModeBadge(flatMode: .gachi)
}
