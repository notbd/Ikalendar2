//
//  EntryView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - EntryView

/// The main entry view of the app.
/// Will set different layout for iPhone and iPad depending on the current horizontal size.
@MainActor
struct EntryView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog

  var body: some View {
    ZStack {
      if isHorizontalCompact {
        RotationsTabsView()
      }
      else {
        RotationsCarouselView()
      }

      if ikaDiscoveryLog.shouldShowOnboarding {
        OnboardingView()
          .zIndex(1)
          .transition(.opacity.animation(.default))
      }
    }
    .task {
      await ikaCatalog.refresh(silently: ikaDiscoveryLog.shouldShowOnboarding)
    }
  }
}

// MARK: - MainView_Previews

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    EntryView()
  }
}
