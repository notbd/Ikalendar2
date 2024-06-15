//
//  SettingsAdvancedOptionsView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsAdvancedOptionsView

@MainActor
struct SettingsAdvancedOptionsView: View {
  typealias Scoped = Constants.Style.Settings.Advanced

  @Environment(IkaStatus.self) private var ikaStatus

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var isBottomToolbarPreviewPresented = false

  @State private var battleRotationPreviewData: BattleRotation = IkaMockData.getBattleRotation()
  @State private var salmonRotationPreviewData: SalmonRotation = IkaMockData.getSalmonRotation()

  @State private var rowWidth: CGFloat = 390

  private var doesNeedPaddedPreview: Bool {
    !isHorizontalCompact && rowWidth > Scoped.PREVIEW_CELL_MAX_WIDTH
  }

  var body: some View {
    GeometryReader { geo in
      List {
        Section {
          rowBottomToolbarPositioningSwitch
          rowAltStageImagesSwitch
        } header: {
          Spacer()
        } footer: {
          if !isHorizontalCompact {
            Text("Certain options only apply to smaller screen widths.")
              .font(.footnote)
          }
          else {
            Spacer()
          }
        }

        Section {
          battleRotationPreviewCell
        } header: { stageImagesPreviewHeader }

        Section {
          salmonRotationPreviewCell
        }
      }
      .navigationTitle("Advanced Options")
      .navigationBarTitleDisplayMode(.large)
      .listStyle(.insetGrouped)
      .sheet(isPresented: $isBottomToolbarPreviewPresented) {
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
    Toggle(isOn: $ikaPreference.shouldSwapBottomToolbarPickers) {
      Label {
        Text("Swap Bottom Toolbar Pickers")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: Scoped.BOTTOM_TOOLBAR_PICKER_POSITIONING_SFSYMBOL)
          .imageScale(.medium)
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(Color.accentColor)
      }
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    .disabled(!isHorizontalCompact)
    .onChange(of: ikaPreference.shouldSwapBottomToolbarPickers) {
      isBottomToolbarPreviewPresented.toggle()
    }
  }

  private var rowAltStageImagesSwitch: some View {
    Toggle(isOn: $ikaPreference.shouldUseAltStageImages) {
      Label {
        Text("Alternative Stage Images")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: Scoped.ALT_STAGE_IMG_SFSYMBOL)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

  private var stageImagesPreviewHeader: some View {
    HStack {
      Text("Preview:")
      Spacer()
      Button {
        withAnimation(.snappy) {
          SimpleHaptics.generateTask(.selection)
          shufflePreviewData()
        }
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
      rowWidth: doesNeedPaddedPreview ? Scoped.PREVIEW_CELL_MAX_WIDTH : rowWidth)
      .if(doesNeedPaddedPreview) {
        $0
          .frame(maxWidth: Scoped.PREVIEW_CELL_MAX_WIDTH)
          .padding()
          .background(Color.systemGroupedBackground)
          .clipShape(.rect(cornerRadius: 10, style: .continuous))
      }
      .hAlignment(.center)
  }

  private var salmonRotationPreviewCell: some View {
    SalmonRotationCell(
      rotation: salmonRotationPreviewData,
      rowWidth: doesNeedPaddedPreview ? Scoped.PREVIEW_CELL_MAX_WIDTH : rowWidth)
      .if(doesNeedPaddedPreview) {
        $0
          .frame(maxWidth: Scoped.PREVIEW_CELL_MAX_WIDTH)
          .padding()
          .background(Color.systemGroupedBackground)
          .clipShape(.rect(cornerRadius: 10, style: .continuous))
      }
      .hAlignment(.center)
  }

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

  @Environment(IkaStatus.self) private var ikaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  var body: some View {
    HStack {
      if !ikaPreference.shouldSwapBottomToolbarPickers {
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
      .environment(IkaStatus.shared)
      .environmentObject(IkaPreference.shared)
  }
}
