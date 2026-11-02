//
//  RotationsCarouselView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - RotationsCarouselView

/// The iPad layout: every mode side by side in a scrolling carousel.
struct RotationsCarouselView: View {
  typealias Scoped = Constants.Style.Carousel

  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaPreference.self) private var ikaPreference

  @Environment(IkaOrientationMonitor.self) private var ikaOrientationMonitor
  private var isLandscape: Bool { ikaOrientationMonitor.currentOrientation.isLandscape }

  @State private var windowWidth: CGFloat = .zero

  private var isWindowWide: Bool { isLandscape && windowWidth >= Scoped.allColumnsMinWidth }

  var body: some View {
    NavigationStack {
      ZStack {
        content
          .navigationTitle(Constants.Key.BundleInfo.appDisplayName)
          .ignoresSafeArea(edges: .bottom)
          .apply {
            setToolbarItems($0)
          }
          .overlay(
            AutoLoadingOverlay(),
            alignment: .bottomTrailing)

        LoadingOverlay()
      }
      .onGeometryChange(for: CGFloat.self) { geo in
        geo.size.width
      } action: { newWidth in
        windowWidth = newWidth
      }
    }
  }

  @ViewBuilder
  private var content: some View {
    switch ikaCatalog.loadResultStatus {
      case .loading:
        ProgressView()
          .hAlignment(.center)
          .vAlignment(.center)

      case .error(let ikaError):
        ErrorView(error: ikaError)

      case .loaded:
        rotationCarouselColumns
    }
  }

  private var rotationCarouselColumns: some View {
    HStack(
      alignment: .top,
      spacing: 0)
    {
      // Workaround (iPadOS, since 51a25f3): without this zero-size leading ScrollView, dragging
      // the first column scrolls the navigation stack instead of the column. Re-check on each
      // iPadOS release.
      if isWindowWide {
        ScrollView {
          Spacer()
            .frame(width: 0, height: 0)
        }
      }

      if ikaPreference.preferredDefaultGameMode == .battle {
        ForEach(BattleMode.allCases) { battleMode in
          sizedColumn(
            CarouselColumn(
              gameMode: .battle,
              battleMode: battleMode))
        }

        sizedColumn(CarouselColumn(gameMode: .salmon))
      }

      else {
        sizedColumn(CarouselColumn(gameMode: .salmon))

        ForEach(BattleMode.allCases) { battleMode in
          sizedColumn(
            CarouselColumn(
              gameMode: .battle,
              battleMode: battleMode))
        }
      }
    }
    .scrollTargetLayout()
    .animation(
      .snappy,
      value: ikaPreference.preferredDefaultGameMode)
    .if(!isWindowWide) { wrapInHorizontalScrollView($0) }
  }

  /// Two columns share the window unless it is wide enough to show them all.
  private func sizedColumn(_ column: CarouselColumn) -> some View {
    column
      .if(!isWindowWide) {
        $0
          .containerRelativeFrame(
            .horizontal,
            count: 2,
            spacing: 0)
      }
  }

  private func wrapInHorizontalScrollView(_ content: some View) -> some View {
    ScrollView(.horizontal) { content }
      .scrollTargetBehavior(.viewAligned)
  }

  private func setToolbarItems(_ content: some View) -> some View {
    content
      .toolbar {
        ToolbarItemGroup(placement: .topBarTrailing) {
          ToolbarRefreshButton()
          ToolbarSettingsButton()
        }
      }
  }
}

#Preview {
  RotationsCarouselView()
    .ikaPreviewEnvironment()
}
