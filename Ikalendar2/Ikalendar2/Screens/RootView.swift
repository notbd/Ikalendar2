//
//  RootView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import SwiftUI

/// The entry view of the app.
/// Provide an interface for some upfront View-level configurations.
struct RootView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var refreshableMainViewID = UUID()

  var body: some View {
    MainView()
      .id(refreshableMainViewID)
      .onReceive(DynamicTextStyleObserver.shared.textSizeDidChange) { refreshViews() }
      .onAppear {
        // Apply correct colorScheme upon launch
        IkaColorSchemeManager.shared.handleColorSchemeChange(for: ikaPreference.preferredAppColorScheme)
      }
      .onChange(of: ikaPreference.preferredAppColorScheme) { selectedColorScheme in
        IkaColorSchemeManager.shared.handleColorSchemeChange(for: selectedColorScheme)
      }
      .if(isHorizontalCompact) {
        $0
          .fullScreenCover(isPresented: $ikaStatus.isSettingsPresented) {
            SettingsMainView()
              .environmentObject(ikaStatus)
              .environmentObject(ikaPreference)
              .accentColor(.orange)
              .interactiveDismissDisabled()
          }
      } else: {
        $0
          .sheet(isPresented: $ikaStatus.isSettingsPresented) {
            SettingsMainView()
              .environmentObject(ikaStatus)
              .environmentObject(ikaPreference)
              .accentColor(.orange)
              .interactiveDismissDisabled()
          }
      }
  }

  // MARK: Lifecycle

  init() {
    // Initial setup of your NavigationBar styles
    UIFontCustomizer.customizeNavigationTitleText()
  }

  // MARK: Private

  /// Force the view(s) to refresh when the text size changes in order to reflect the new NavBar title size.
  private func refreshViews() {
    refreshableMainViewID = UUID()
  }
}
