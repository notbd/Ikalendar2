//
//  RotationsCarouselView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - RotationsCarouselView

struct RotationsCarouselView: View {
  typealias Scoped = Constants.Style.Carousel

  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var windowWidth: CGFloat = .zero

  private var isWindowWide: Bool { windowWidth >= 1024 }

  var body: some View {
    ZStack {
      content
        .apply(setToolbarItems)
        .navigationTitle(Constants.Key.BundleInfo.APP_DISPLAY_NAME)
        .overlay(
          AutoLoadingOverlay(autoLoadStatus: ikaCatalog.autoLoadStatus),
          alignment: .bottomTrailing)

      LoadingOverlay(loadStatus: ikaCatalog.loadStatus)
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

  private var content: some View {
    Group {
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
  }

  private var rotationCarouselColumns: some View {
    HStack(
      alignment: .top,
      spacing: 0)
    {
      // avoid the scroll of the first column causing the whole navigation stack to scroll
      if isWindowWide {
        ScrollView {
          Spacer()
            .frame(width: 0, height: 0)
        }
      }

      if ikaPreference.defaultGameMode == .battle {
        ForEach(BattleMode.allCases) { battleMode in
          CarouselColumn(
            gameMode: .battle,
            battleMode: battleMode)
            .if(!isWindowWide) { $0.frame(width: Scoped.COLUMN_FIXED_WIDTH) }
        }

        CarouselColumn(gameMode: .salmon)
          .if(!isWindowWide) { $0.frame(width: Scoped.COLUMN_FIXED_WIDTH) }
      }

      else {
        CarouselColumn(gameMode: .salmon)
          .if(!isWindowWide) { $0.frame(width: Scoped.COLUMN_FIXED_WIDTH) }

        ForEach(BattleMode.allCases) { battleMode in
          CarouselColumn(
            gameMode: .battle,
            battleMode: battleMode)
            .if(!isWindowWide) { $0.frame(width: Scoped.COLUMN_FIXED_WIDTH) }
        }
      }
    }
    .animation(
      Constants.Config.Animation.appDefault,
      value: ikaPreference.defaultGameMode)
    .if(!isWindowWide) { wrapInHorizontalScrollView(content: $0) }
  }

  // MARK: Private

  private func wrapInHorizontalScrollView(content: some View) -> some View {
    ScrollView(.horizontal) { content }
  }

  private func setToolbarItems(content: some View) -> some View {
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
