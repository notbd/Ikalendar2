//
//  SettingsAdvancedOptionsView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsAdvancedOptionsView

struct SettingsAdvancedOptionsView: View {
  typealias Scoped = Constants.Style.Settings.Advanced

  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var ifBottomToolbarPreviewPresented = false

  @State private var battleRotationPreviewData: BattleRotation = IkaMockData.getBattleRotation()
  @State private var salmonRotationPreviewData: SalmonRotation = IkaMockData.getSalmonRotation()

  @State private var rowWidth: CGFloat = 390 // initial value does not matter

  var body: some View {
    GeometryReader { geo in
      List {
        Section(
          header: Spacer(),
          footer: Spacer())
        {
          rowBottomToolbarPositioningSwitch
          rowAltStageImagesSwitch
        }

        Section(header: stageImagesPreviewHeader) {
          battleRotationPreviewCell
            .animation(
              Constants.Config.Animation.appDefault,
              value: battleRotationPreviewData)
        }

        Section {
          salmonRotationPreviewCell
            .animation(
              Constants.Config.Animation.appDefault,
              value: salmonRotationPreviewData)
        }
      }
      .navigationTitle("Advanced Options")
      .navigationBarTitleDisplayMode(.large)
      .listStyle(.insetGrouped)
      .sheet(isPresented: $ifBottomToolbarPreviewPresented) {
        BottomToolbarPositioningPreview()
          .presentationDetents([.fraction(Scoped.BOTTOM_TOOLBAR_PREVIEW_SHEET_DETENTS_FRACTION)])
          .presentationCornerRadius(0)
          .presentationBackground(.ultraThinMaterial)
          .interactiveDismissDisabled()
      }
      .onChange(of: geo.size, initial: true) { _, newVal in
        rowWidth = newVal.width
      }
    }
  }

  private var rowBottomToolbarPositioningSwitch: some View {
    Toggle(isOn: $ikaPreference.ifSwapBottomToolbarPickers) {
      Label(
        "Swap Bottom Toolbar Pickers",
        systemImage: Scoped.BOTTOM_TOOLBAR_PICKER_POSITIONING_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    .onChange(of: ikaPreference.ifSwapBottomToolbarPickers) {
      ifBottomToolbarPreviewPresented.toggle()
    }
  }

  private var rowAltStageImagesSwitch: some View {
    Toggle(isOn: $ikaPreference.ifUseAltStageImages) {
      Label(
        "Alternative Stage Images",
        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

  private var stageImagesPreviewHeader: some View {
    HStack {
      Text("Preview:")
      Spacer()
      Button {
        SimpleHaptics.generateTask(.selection)
        shufflePreviewData()
      } label: {
        Label(
          "Shuffle",
          systemImage: Scoped.ALT_STAGE_PREVIEW_SHUFFLE_SFSYMBOL)
          .font(.footnote.bold())
      }
    }
  }

  private var battleRotationPreviewCell: some View {
    BattleRotationCell(
      type: .primary,
      rotation: battleRotationPreviewData,
      rowWidth: rowWidth)
  }

  private var salmonRotationPreviewCell: some View {
    SalmonRotationCell(
      rotation: salmonRotationPreviewData,
      rowWidth: rowWidth)
  }

  // MARK: Private

  private func shufflePreviewData() {
    // make sure stages are different
    var newBattleData = IkaMockData.getBattleRotation()
    var newSalmonData = IkaMockData.getSalmonRotation()

    while
      newBattleData.rule == battleRotationPreviewData.rule ||
      newBattleData.stageA == battleRotationPreviewData.stageA ||
      newBattleData.stageB == battleRotationPreviewData.stageB
    {
      newBattleData = IkaMockData.getBattleRotation()
    }
    while newSalmonData.stage == salmonRotationPreviewData.stage {
      newSalmonData = IkaMockData.getSalmonRotation()
    }

    battleRotationPreviewData = newBattleData
    salmonRotationPreviewData = newSalmonData
  }
}

// MARK: - BottomToolbarPositioningPreview

struct BottomToolbarPositioningPreview: View {
  typealias Scoped = Constants.Style.Settings.Advanced

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
    .padding(.horizontal, Scoped.BOTTOM_TOOLBAR_PREVIEW_PADDING_H)
    .task {
      try? await Task.sleep(
        nanoseconds: UInt64(Scoped.BOTTOM_TOOLBAR_PREVIEW_LINGER_INTERVAL * 1_000_000_000))
      dismiss()
    }
  }

  private var battleModePicker: some View {
    Picker(
      selection: .constant(ikaStatus.currentBattleMode),
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
          systemName: ikaStatus.currentGameMode == gameMode
            ? gameMode.sfSymbolNameSelected
            : gameMode.sfSymbolNameIdle)
          .tag(gameMode)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
    .fixedSize()
  }
}

// MARK: - SettingsAdvancedOptionsView_Previews

struct SettingsAdvancedOptionsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAdvancedOptionsView()
      .environmentObject(IkaStatus())
      .environmentObject(IkaPreference())
  }
}
