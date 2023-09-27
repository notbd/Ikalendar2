//
//  MainView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - MainView

/// The main view of the app.
/// Will set different layout for iPhone and iPad depending on the current horizontal size.
@MainActor
struct MainView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(IkaCatalog.self) private var ikaCatalog
  @EnvironmentObject private var ikaLog: IkaLog

  var body: some View {
    ZStack {
      NavigationStack {
        if isHorizontalCompact { RotationsSingularView() }
        else { RotationsCarouselView() }
      }
      .onChange(of: ikaLog.hasFinishedOnboarding, initial: true) { _, newVal in
        if newVal {
          Task {
            await ikaCatalog.refresh()
          }
        }
      }

      if !ikaLog.hasFinishedOnboarding {
        OnboardingView()
          .zIndex(1)
          .transition(.opacity.animation(.default))
      }
    }
  }
}

// MARK: - MainView_Previews

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
