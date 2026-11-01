//
//  RotationsTabView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - RotationsTabView

/// One tab's content for `flatMode`: its rotation list (or ErrorView), the mode stamp that docks
/// into a nav bar badge on scroll, and pull-to-refresh.
struct RotationsTabView: View {
  @Environment(IkaCatalog.self) private var ikaCatalog

  let flatMode: FlatMode

  /// Driven by the scroll distance from the top of the list, not by the nav bar's safe area:
  /// that inset does not shrink as the large title collapses but jumps by the full title height
  /// at the end. Clamped in the transform, so scrolling past the dock travel updates nothing.
  @State private var dockProgress: Double = 0

  var body: some View {
    ZStack {
      content
        .navigationTitle(title.localizedStringKey)
        .onScrollGeometryChange(for: Double.self) { geometry in
          ModeIconStamp.dockProgress(travel: geometry.contentOffset.y + geometry.contentInsets.top)
        } action: { _, progress in
          dockProgress = progress
        }
        .overlay(
          ModeIconStamp(
            flatModeSelection: flatMode,
            dockProgress: dockProgress)
            .offset(
              x: Constants.Style.Overlay.ModeIcon.iconOffsetX,
              y: Constants.Style.Overlay.ModeIcon.iconOffsetY),
          alignment: .topTrailing)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            ModeBadge(flatMode: flatMode)
              .opacity(ModeIconStamp.badgeOpacity(progress: dockProgress))
              .allowsHitTesting(false)
          }
          // The badge draws its own glass, so the glass fades in with the badge.
          .sharedBackgroundVisibility(.hidden)
        }
        .refreshable {
          await ikaCatalog.refresh()
        }

      LoadingOverlay()
    }
  }

  @ViewBuilder
  private var content: some View {
    switch ikaCatalog.loadResultStatus {
      case .error(let ikaError):
        ErrorView(error: ikaError)
      case .loading,
           .loaded:
        rotationList
    }
  }

  @ViewBuilder
  private var rotationList: some View {
    if let battleMode = flatMode.battleMode {
      BattleRotationList(battleMode: battleMode)
    }
    else {
      SalmonRotationList()
    }
  }

  private var title: String {
    flatMode.name
  }
}

#Preview("Battle Tab") {
  RotationsTabView(flatMode: .gachi)
    .ikaPreviewEnvironment()
}

#Preview("Salmon Tab") {
  RotationsTabView(flatMode: .salmon)
    .ikaPreviewEnvironment()
}
