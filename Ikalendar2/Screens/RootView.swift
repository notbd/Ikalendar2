//
//  RootView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// The entry view of the app.
/// Provide an interface for some upfront View-level configurations.
struct RootView: View {
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  var body: some View {
    MainView()
      .onAppear {
        // Apply correct colorScheme upon launch
        IkaColorSchemeManager.shared.handleColorSchemeChange(for: ikaPreference.preferredAppColorScheme)
      }
      .onChange(of: ikaPreference.preferredAppColorScheme) { selectedColorScheme in
        IkaColorSchemeManager.shared.handleColorSchemeChange(for: selectedColorScheme)
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
    UIKitIntegration.customizeNavigationTitleText()
//    UIKitIntegration.customizePickerText()
  }
}
