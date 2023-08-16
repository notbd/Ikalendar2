//
//  RotationsView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - RotationsView

/// The view that displays the content in a NavigationView.
struct RotationsView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @EnvironmentObject var ikaCatalog: IkaCatalog
  @EnvironmentObject var ikaStatus: IkaStatus

  var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  var body: some View {
    ZStack {
      content
        .if(isHorizontalCompact) {
          setCompactHoriClassToolbar(content: $0)
        } else: {
          $0
        }
        .navigationTitle(title)
        .refreshable {
          await ikaCatalog.loadCatalog()
        }
        .overlay(
          ModeIconStamp(),
          alignment: .topTrailing)
        .overlay(
          AutoLoadingOverlay(autoLoadStatus: ikaCatalog.autoLoadStatus),
          alignment: .bottomTrailing)

      LoadingOverlay(loadStatus: ikaCatalog.loadStatus)
    }
  }

  var content: some View {
    Group {
      switch ikaCatalog.loadStatusWithLoadingDropped {
      case .error(let ikaError):
        ErrorView(error: ikaError)
      default:
        switch ikaStatus.gameModeSelection {
        case .battle:
          BattleRotationListView()
        case .salmon:
          SalmonRotationListView()
        }
      }
    }
  }

  var title: LocalizedStringKey {
    switch ikaStatus.gameModeSelection {
    case .battle:
      return ikaStatus.battleModeSelection.name.localizedStringKey()
    case .salmon:
      return ikaStatus.gameModeSelection.name.localizedStringKey()
    }
  }

  // MARK: Internal

  func setCompactHoriClassToolbar(content: some View) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          ToolbarSettingsButton(
            action: didTapSettingsButton)
        }

        ToolbarItemGroup(placement: .bottomBar) {
          if ikaStatus.gameModeSelection == .battle {
            ToolbarBattleModePicker()
          }

          Spacer()

          ToolbarGameModePicker()
        }
      }
  }


  func didTapSettingsButton() {
    SimpleHaptics.generateTask(.selection)
    ikaStatus.isSettingsPresented.toggle()
  }
}

// MARK: - ToolbarBattleModePicker

/// A picker component for the battle mode
struct ToolbarBattleModePicker: View {
  @EnvironmentObject var ikaStatus: IkaStatus

  var body: some View {
    Picker(
      selection: $ikaStatus.battleModeSelection
        .onSet { _ in SimpleHaptics.generateTask(.soft) },
      label: Text("Battle Mode"))
    {
      ForEach(BattleMode.allCases) { battleMode in
        Text(battleMode.shortName.localizedStringKey())
          .tag(battleMode)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}

// MARK: - ToolbarGameModePicker

/// A picker component for the game mode
struct ToolbarGameModePicker: View {
  @EnvironmentObject var ikaStatus: IkaStatus

  var body: some View {
    Picker(
      selection: $ikaStatus.gameModeSelection
        .onSet { _ in SimpleHaptics.generateTask(.soft) },
      label: Text("Game Mode"))
    {
      ForEach(GameMode.allCases) { gameMode in
        Label(
          gameMode.name.localizedStringKey(),
          systemImage: ikaStatus.gameModeSelection == gameMode
            ? gameMode.sfSymbolSelected
            : gameMode.sfSymbolIdle)
          .tag(gameMode)
      }
    }
    .pickerStyle(SegmentedPickerStyle())
  }
}

// MARK: - RotationView_Previews

struct RotationView_Previews: PreviewProvider {
  static var previews: some View {
    RotationsView()
      .environmentObject(IkaCatalog.shared)
  }
}
