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
  @Environment(\.dynamicTypeSize) var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference
  @EnvironmentObject private var ikaLog: IkaLog

  @State private var refreshableMainViewID = UUID()

  var body: some View {
    MainView()
      .id(refreshableMainViewID)
      .onChange(of: dynamicTypeSize) {
        UIFontCustomizer.customizeNavigationTitleText()
        refreshViews()
      }
      .onChange(of: ikaPreference.preferredAppColorScheme, initial: true) { _, newVal in
        IkaColorSchemeManager.shared.handlePreferredColorSchemeChange(for: newVal)
      }
      .if(isHorizontalCompact) { setUpFullScreenCoverSettingsModal($0) }
      else: { setUpSheetSettingsModal($0) }
  }

  private var settingsModal: some View {
    SettingsMainView()
      .environmentObject(ikaStatus)
      .environmentObject(ikaPreference)
      .environmentObject(ikaLog)
      .accentColor(.orange)
      .overlay(
        AutoLoadingOverlay(),
        alignment: .bottomTrailing)
      .interactiveDismissDisabled()
  }

  // MARK: Lifecycle

  init() {
    // Initial setup of your NavigationBar styles
    UIFontCustomizer.customizeNavigationTitleText()
  }

  // MARK: Private

  private func setUpFullScreenCoverSettingsModal(_ content: some View) -> some View {
    content.fullScreenCover(isPresented: $ikaStatus.isSettingsPresented) { settingsModal }
  }

  private func setUpSheetSettingsModal(_ content: some View) -> some View {
    content.sheet(isPresented: $ikaStatus.isSettingsPresented) { settingsModal }
  }

  /// Stupid workaround because as of iOS 17, dynamicTypeSize changes will not affect navigation titles,
  /// therefore force refresh the root view in order to reflect the correct title size.
  private func refreshViews() {
    refreshableMainViewID = UUID()
  }
}
