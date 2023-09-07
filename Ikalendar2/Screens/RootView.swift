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
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var refreshableID = UUID()

  var body: some View {
    MainView()
      .id(refreshableID)
      .onAppear {
        // Apply correct colorScheme upon launch
        IkaColorSchemeManager.shared.handleColorSchemeChange(for: ikaPreference.preferredAppColorScheme)
      }
      .onChange(of: ikaPreference.preferredAppColorScheme) { selectedColorScheme in
        IkaColorSchemeManager.shared.handleColorSchemeChange(for: selectedColorScheme)
      }
      .onReceive(DynamicTextStyleObserver.shared.textSizeDidChange) {
        // force the view to refresh when the text size changes
        refreshableID = UUID()
      }
      .fullScreenCover(isPresented: $ikaStatus.isSettingsPresented) {
        SettingsMainView()
          .environmentObject(ikaStatus)
          .environmentObject(ikaPreference)
          .accentColor(.orange)
          .interactiveDismissDisabled()
      }
  }

  // MARK: Lifecycle

  init() {
    // Initial setup of your NavigationBar styles
    UIFontCustomizer.customizeNavigationTitleText()
  }
}
