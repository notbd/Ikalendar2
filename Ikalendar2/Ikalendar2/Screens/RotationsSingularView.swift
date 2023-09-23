//
//  RotationsSingularView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - RotationsSingularView

/// The view that displays the content in a NavigationView.
struct RotationsSingularView: View {
  @EnvironmentObject private var ikaCatalog: IkaCatalog
  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  var body: some View {
    ZStack {
      content
        .apply(setToolbarItems)
        .navigationTitle(title.localizedStringKey)
        .overlay(
          ModeIconStamp(
            gameModeSelection: ikaStatus.currentGameMode,
            battleModeSelection: ikaStatus.currentBattleMode,
            ifOffset: true)
            .animation(
              .snappy,
              value: "\(ikaStatus.currentGameMode)-\(ikaStatus.currentBattleMode)"),

          alignment: .topTrailing)
        .overlay(
          AutoLoadingOverlay(),
          alignment: .bottomTrailing)
        .refreshable {
          // Note: As of iOS 17.0 SDK, refresh operation must be wrapped inside a Task.
          //  Failing to do so results in SwiftUI altering the view hierarchy upon pull-to-refresh, leading
          //  to unintentional destruction of views and the subsequent cancellation of the network task.
          await Task { await ikaCatalog.refresh() }.value
        }

      LoadingOverlay(loadStatus: ikaCatalog.loadStatus)
    }
  }

  @ViewBuilder
  private var content: some View {
    switch ikaCatalog.loadResultStatus {
    case .error(let ikaError):
      ErrorView(error: ikaError)
    default:
      rotationList
    }
  }

  @ViewBuilder
  private var rotationList: some View {
    switch ikaStatus.currentGameMode {
    case .battle:
      BattleRotationList()
    case .salmon:
      SalmonRotationList()
    }
  }

  private var title: String {
    switch ikaStatus.currentGameMode {
    case .battle:
      ikaStatus.currentBattleMode.name
    case .salmon:
      ikaStatus.currentGameMode.name
    }
  }

  // MARK: Private

  private func setToolbarItems(content: some View) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          ToolbarSettingsButton()
        }

        ToolbarItemGroup(placement: .bottomBar) {
          if !ikaPreference.ifSwapBottomToolbarPickers {
            // keep order
            if ikaStatus.currentGameMode == .battle {
              ToolbarBattleModePicker()
            }
            Spacer()
            ToolbarGameModePicker()
          }
          else {
            // swap order
            ToolbarGameModePicker()
            Spacer()
            if ikaStatus.currentGameMode == .battle {
              ToolbarBattleModePicker()
            }
          }
        }
      }
  }
}

// MARK: - ToolbarBattleModePicker

/// A picker component for the battle mode
struct ToolbarBattleModePicker: View {
  @EnvironmentObject private var ikaStatus: IkaStatus

  var body: some View {
    Picker(
      selection: $ikaStatus.currentBattleMode,
      label: Text("Battle Mode"))
    {
      ForEach(BattleMode.allCases) { battleMode in
        Text(battleMode.shortName.localizedStringKey)
          .tag(battleMode)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}

// MARK: - ToolbarGameModePicker

/// A picker component for the game mode
struct ToolbarGameModePicker: View {
  @EnvironmentObject private var ikaStatus: IkaStatus

  var body: some View {
    Picker(
      selection: $ikaStatus.currentGameMode,
      label: Text("Game Mode"))
    {
      ForEach(GameMode.allCases) { gameMode in
        Label(
          gameMode.name.localizedStringKey,
          systemImage: ikaStatus.currentGameMode == gameMode
            ? gameMode.sfSymbolNameSelected
            : gameMode.sfSymbolNameIdle)
          .tag(gameMode)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}

// MARK: - RotationView_Previews

struct RotationView_Previews: PreviewProvider {
  static var previews: some View {
    RotationsSingularView()
      .environmentObject(IkaCatalog.shared)
  }
}
