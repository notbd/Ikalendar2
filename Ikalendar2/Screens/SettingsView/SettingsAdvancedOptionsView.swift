//
//  SettingsAdvancedOptionsView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsAdvancedOptionsView

/// The Settings page for the more niche toggles, with live preview cells.
struct SettingsAdvancedOptionsView: View {
  typealias Scoped = Constants.Style.Settings.Advanced

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(IkaPreference.self) private var ikaPreference

  @State private var battleRotationPreviewData: BattleRotation = IkaMockData.makeBattleRotation()
  @State private var salmonRotationPreviewData: SalmonRotation = IkaMockData.makeSalmonRotation()

  @State private var rowWidth: CGFloat = 390

  private var doesNeedPaddedPreview: Bool {
    !isHorizontalCompact && rowWidth > Scoped.previewCellMaxWidth
  }

  var body: some View {
    GeometryReader { geo in
      List {
        Section {
          rowTabBarMinimizingSwitch
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
      .onChange(of: geo.size, initial: true) { _, newVal in
        rowWidth = newVal.width
      }
    }
  }

  private var rowTabBarMinimizingSwitch: some View {
    @Bindable var ikaPreference = ikaPreference
    return Toggle(isOn: $ikaPreference.shouldMinimizeTabBar) {
      Label {
        Text("Minimize Tab Bar")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: ikaPreference.shouldMinimizeTabBar
          ? Scoped.tabBarMinimizingOnSFSymbol
          : Scoped.tabBarMinimizingOffSFSymbol)
          .imageScale(.medium)
          .contentTransition(.symbolEffect(.replace.magic(fallback: .replace.byLayer)))
          .symbolRenderingMode(.monochrome)
          .foregroundStyle(Color.accentColor)
      }
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    .disabled(!isHorizontalCompact)
  }

  private var rowAltStageImagesSwitch: some View {
    @Bindable var ikaPreference = ikaPreference
    return Toggle(isOn: $ikaPreference.shouldUseAltStageImages) {
      Label {
        Text("Alternative Stage Images")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: Scoped.altStageImgSFSymbol)
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
          systemImage: Scoped.altStagePreviewShuffleSFSymbol)
          .font(.footnote.bold())
      }
    }
  }

  private var battleRotationPreviewCell: some View {
    BattleRotationCell(
      type: .primary,
      rotation: battleRotationPreviewData,
      rowWidth: doesNeedPaddedPreview ? Scoped.previewCellMaxWidth : rowWidth)
      .if(doesNeedPaddedPreview) {
        $0
          .frame(maxWidth: Scoped.previewCellMaxWidth)
          .padding()
          .background(Color.systemGroupedBackground)
          .clipShape(.rect(cornerRadius: 28, style: .continuous))
      }
      .hAlignment(.center)
  }

  private var salmonRotationPreviewCell: some View {
    SalmonRotationCell(
      rotation: salmonRotationPreviewData,
      rowWidth: doesNeedPaddedPreview ? Scoped.previewCellMaxWidth : rowWidth)
      .if(doesNeedPaddedPreview) {
        $0
          .frame(maxWidth: Scoped.previewCellMaxWidth)
          .padding()
          .background(Color.systemGroupedBackground)
          .clipShape(.rect(cornerRadius: 28, style: .continuous))
      }
      .hAlignment(.center)
  }

  private func shufflePreviewData() {
    // make sure stages are different
    var newBattleData: BattleRotation = IkaMockData.makeBattleRotation()
    var newSalmonData: SalmonRotation = IkaMockData.makeSalmonRotation()

    while
      newBattleData.rule == battleRotationPreviewData.rule ||
      newBattleData.stageA == battleRotationPreviewData.stageA ||
      newBattleData.stageB == battleRotationPreviewData.stageB
    {
      newBattleData = IkaMockData.makeBattleRotation()
    }
    while newSalmonData.stage == salmonRotationPreviewData.stage {
      newSalmonData = IkaMockData.makeSalmonRotation()
    }

    battleRotationPreviewData = newBattleData
    salmonRotationPreviewData = newSalmonData
  }
}

#Preview {
  NavigationStack {
    SettingsAdvancedOptionsView()
  }
  .ikaPreviewEnvironment()
}
