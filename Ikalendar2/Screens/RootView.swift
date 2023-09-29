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
@MainActor
struct RootView: View {
  @Environment(\.dynamicTypeSize) var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(IkaStatus.self) private var ikaStatus

  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var entryViewID = UUID()

  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  var body: some View {
    EntryView()
      .id(entryViewID)
      .onChange(of: dynamicTypeSize) {
        UIFontCustomizer.customizeNavigationTitleText()
        refreshEntryView()
      }
      .onChange(of: ikaPreference.preferredAppColorScheme, initial: true) { _, newVal in
        IkaColorSchemeManager.shared.handlePreferredColorSchemeChange(for: newVal)
      }
      .if(isHorizontalCompact) { setUpFullScreenCoverSettingsModal($0) }
      else: { setUpSheetSettingsModal($0) }
  }

  private var settingsModal: some View {
    SettingsEntryView()
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
    @Bindable var ikaStatus = ikaStatus
    return
      content.fullScreenCover(isPresented: $ikaStatus.isSettingsPresented) { settingsModal }
  }

  private func setUpSheetSettingsModal(_ content: some View) -> some View {
    @Bindable var ikaStatus = ikaStatus
    return
      content.sheet(isPresented: $ikaStatus.isSettingsPresented) { settingsModal }
  }

  /// Stupid workaround because as of iOS 17.0, dynamicTypeSize changes will not affect navigation titles,
  /// therefore force refresh the root view in order to reflect the correct title size.
  private func refreshEntryView() {
    entryViewID = UUID()
  }
}
