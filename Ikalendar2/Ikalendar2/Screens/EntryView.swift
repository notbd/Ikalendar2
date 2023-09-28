//
//  EntryView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
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
  @EnvironmentObject private var ikaLog: IkaLog

  var body: some View {
    ZStack {
      NavigationStack {
        if isHorizontalCompact {
          RotationsSingularView()
        }
        else {
          RotationsCarouselView()
        }
      }

      if ikaLog.shouldShowOnboarding {
        OnboardingView()
          .zIndex(1)
          .transition(.opacity.animation(.default))
      }
    }
    .task {
      await ikaCatalog.refresh(silently: ikaLog.shouldShowOnboarding)
    }
  }
}

// MARK: - MainView_Previews

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    EntryView()
  }
}
