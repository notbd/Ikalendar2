//
//  RotationsTabsView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// The compact-width layout (iPhone, and iPad in Slide Over or a narrow split): one tab per mode
/// along the bottom bar.
struct RotationsTabsView: View {
  @Environment(IkaStatus.self) private var ikaStatus

  @Environment(IkaPreference.self) private var ikaPreference

  var body: some View {
    @Bindable var ikaStatus = ikaStatus

    TabView(selection: $ikaStatus.currentFlatMode) {
      ForEach(FlatMode.allCases) { flatMode in
        Tab(
          flatMode.shortName.localizedStringKey,
          systemImage: flatMode.sfSymbolNameSelected,
          value: flatMode)
        {
          NavigationStack {
            RotationsTabView(flatMode: flatMode)
              .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                  ToolbarSettingsButton()
                }
              }
          }
          .overlay(
            AutoLoadingOverlay(),
            alignment: .bottomTrailing)
        }
      }
    }
    .tabBarMinimizeBehavior(ikaPreference.shouldMinimizeTabBar ? .onScrollDown : .automatic)
  }
}

#Preview {
  RotationsTabsView()
    .ikaPreviewEnvironment()
}
