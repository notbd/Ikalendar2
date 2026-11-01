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

  /// Driven by the scroll distance from where the list rests under the expanded large title, not
  /// from the current top inset: that inset shrinks by the title height as the title collapses
  /// (gradually under a drag, in one step at the end of a programmatic scroll) and stays shrunk
  /// when rows above are removed while scrolled. Clamped in the transform, so scrolling past the
  /// dock travel updates nothing.
  @State private var dockProgress: Double = 0
  /// The list's top content inset at rest under the expanded large title.
  @State private var restingTopInset: CGFloat = 0

  var body: some View {
    ZStack {
      content
        .navigationTitle(title.localizedStringKey)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
          geometry.contentInsets.top
        } action: { _, topInset in
          // Kept from the first layout, where the large title is expanded: later insets also
          // grow by the pull-to-refresh spinner.
          if restingTopInset == 0 { restingTopInset = topInset }
        }
        .onScrollGeometryChange(for: Double.self) { [restingTopInset] geometry in
          ModeIconStamp.dockProgress(contentOffsetY: geometry.contentOffset.y, restingTopInset: restingTopInset)
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
