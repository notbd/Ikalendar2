//
//  SettingsAdvancedOptionsView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsAdvancedOptionsView

struct SettingsAdvancedOptionsView: View {
  typealias Scoped = Constants.Styles.Settings.Advanced

  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var ifBottomToolbarPreviewPresented = false

  //  let battleRotationExample =
  //    IkaMockData.getBattleRotation(rule: BattleRule.allCases.randomElement()!)
  //  let salmonRotationExample = IkaMockData.getSalmonRotation()

  var body: some View {
    List {
      Section(header: Spacer()) {
        rowAltStageImagesToggle
      }

      Section {
        rowBottomToolbarPositioning
      }
    }
    .navigationTitle("Advanced Options")
    .navigationBarTitleDisplayMode(.large)
    .sheet(isPresented: $ifBottomToolbarPreviewPresented) {
      BottomToolbarPositioningPreview()
        .presentationDetents([.fraction(Scoped.BOTTOM_TOOLBAR_PREVIEW_SHEET_DETENTS_FRACTION)])
        .presentationCornerRadius(0)
        .presentationBackground(.ultraThinMaterial)
        .interactiveDismissDisabled()
    }
    .listStyle(.insetGrouped)
  }

  private var rowAltStageImagesToggle: some View {
    // placeholder
    Toggle(isOn: .constant(true)) {
      Label(
        "Alternative Stage Images",
        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

  private var rowBottomToolbarPositioning: some View {
    Toggle(isOn: $ikaPreference.ifSwapBottomToolbarPickers) {
      Label(
        "Swap Bottom Toolbar Pickers",
        systemImage: Scoped.BOTTOM_TOOLBAR_PICKER_POSITIONING_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    .onChange(of: ikaPreference.ifSwapBottomToolbarPickers) { _ in
      ifBottomToolbarPreviewPresented.toggle()
    }
  }
}

// MARK: - BottomToolbarPositioningPreview

struct BottomToolbarPositioningPreview: View {
  typealias Scoped = Constants.Styles.Settings.Advanced

  @Environment(\.dismiss) private var dismiss

  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  var body: some View {
    HStack {
      if !ikaPreference.ifSwapBottomToolbarPickers {
        // keep order
        battleModePicker
        Spacer()
        gameModePicker
      }
      else {
        // swap order
        gameModePicker
        Spacer()
        battleModePicker
      }
    }
    .padding(.horizontal, Scoped.BOTTOM_TOOLBAR_PREVIEW_PADDING_HORIZONTAL)
    .task {
      try? await Task.sleep(
        nanoseconds: UInt64(Scoped.BOTTOM_TOOLBAR_PREVIEW_LINGER_INTERVAL * 1_000_000_000))
      dismiss()
    }
  }

  private var battleModePicker: some View {
    Picker(
      selection: .constant(ikaStatus.battleModeSelection),
      label: Text("Battle Mode"))
    {
      ForEach(BattleMode.allCases) { battleMode in
        Text(battleMode.shortName.localizedStringKey)
          .tag(battleMode)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
    .fixedSize()
  }

  private var gameModePicker: some View {
    Picker(
      selection: .constant(GameMode.battle),
      label: Text("Game Mode"))
    {
      ForEach(GameMode.allCases) { gameMode in
        Image(
          systemName: ikaStatus.gameModeSelection == gameMode
            ? gameMode.sfSymbolSelected
            : gameMode.sfSymbolIdle)
          .tag(gameMode)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
    .fixedSize()
  }
}
