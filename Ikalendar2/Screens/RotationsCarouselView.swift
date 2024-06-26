//
//  RotationsCarouselView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - RotationsCarouselView

@MainActor
struct RotationsCarouselView: View {
  typealias Scoped = Constants.Style.Carousel

  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaStatus.self) private var ikaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @Environment(IkaInterfaceOrientationPublisher.self) private var ikaInterfaceOrientationPublisher
  private var isLandscape: Bool { ikaInterfaceOrientationPublisher.currentOrientation.isLandscape }

  @State private var windowWidth: CGFloat = .zero

  private var isWindowWide: Bool { isLandscape && windowWidth >= 1024 }

  var body: some View {
    ZStack {
      content
        .navigationTitle(Constants.Key.BundleInfo.APP_DISPLAY_NAME)
        .ignoresSafeArea(edges: .bottom)
        .apply {
          setToolbarItems($0)
        }
        .overlay(
          AutoLoadingOverlay(),
          alignment: .bottomTrailing)

      LoadingOverlay()
    }
    .background {
      GeometryReader { geo in
        Color.clear
          .onChange(of: geo.size, initial: true) { _, newVal in
            windowWidth = newVal.width
          }
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
      // Stupid workaround to avoid the fact that scrolling of the first
      // column will cause the whole navigation stack to scroll
      if isWindowWide {
        ScrollView {
          Spacer()
            .frame(width: 0, height: 0)
        }
      }

      if ikaPreference.preferredDefaultGameMode == .battle {
        ForEach(BattleMode.allCases) { battleMode in
          CarouselColumn(
            gameMode: .battle,
            battleMode: battleMode)
            .if(!isWindowWide) {
              $0
                .containerRelativeFrame(
                  .horizontal,
                  count: 2,
                  spacing: 0)
            }
        }

        CarouselColumn(gameMode: .salmon)
          .if(!isWindowWide) {
            $0
              .containerRelativeFrame(
                .horizontal,
                count: 2,
                spacing: 0)
          }
      }

      else {
        CarouselColumn(gameMode: .salmon)
          .if(!isWindowWide) {
            $0
              .containerRelativeFrame(
                .horizontal,
                count: 2,
                spacing: 0)
          }

        ForEach(BattleMode.allCases) { battleMode in
          CarouselColumn(
            gameMode: .battle,
            battleMode: battleMode)
            .if(!isWindowWide) {
              $0
                .containerRelativeFrame(
                  .horizontal,
                  count: 2,
                  spacing: 0)
            }
        }
      }
    }
    .scrollTargetLayout()
    .animation(
      .snappy,
      value: ikaPreference.preferredDefaultGameMode)
    .if(!isWindowWide) { wrapInHorizontalScrollView($0) }
  }

  @MainActor
  private func wrapInHorizontalScrollView(_ content: some View) -> some View {
    ScrollView(.horizontal) { content }
      .scrollTargetBehavior(.viewAligned)
  }

  @MainActor
  private func setToolbarItems(_ content: some View) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            ToolbarRefreshButton()
            ToolbarSettingsButton()
          }
        }
      }
  }
}

// MARK: - RotationsCarouselView_Previews

struct RotationsCarouselView_Previews: PreviewProvider {
  static var previews: some View {
    RotationsCarouselView()
  }
}
