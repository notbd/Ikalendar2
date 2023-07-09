//
//  ContentView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ContentView

/// The view that displays the content in a NavigationView.
struct ContentView: View {
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
          setRegularHoriClassToolbar(content: $0)
        }
        .navigationTitle(title)
        .refreshable {
          ikaCatalog.refreshCatalog()
        }
        .overlay(
          ModeIconStamp(),
          alignment: .topTrailing)
        .overlay(
          AutoLoadingOverlay(autoLoadingStatus: ikaCatalog.autoLoadingStatus),
          alignment: .bottomTrailing)

      LoadingOverlay(loadingStatus: ikaCatalog.loadingStatus)
    }
  }

  var content: some View {
    Group {
      switch ikaCatalog.loadedVSErrorStatus {
      // For better visual: not switch content during loading
      case .error(let ikaError):
        ErrorView(error: ikaError)
      case .loaded:
        switch ikaStatus.gameModeSelection {
        case .battle:
          BattleRotationListView()
        case .salmon:
          SalmonRotationListView()
        }
      default:
        Spacer()
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

  func setCompactHoriClassToolbar<Content: View>(content: Content) -> some View {
    content
      .toolbar {
//        ToolbarItem(placement: .navigationBarLeading) {
//          ToolbarRefreshButton(
//            isDisabled: ikaCatalog.loadingStatus == .loading,
//            action: didTapRefreshButton)
//        }

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

  func setRegularHoriClassToolbar<Content: View>(content: Content) -> some View {
    content
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          ToolbarRefreshButton(
            isDisabled: ikaCatalog.loadingStatus == .loading,
            action: didTapRefreshButton)
        }
      }
  }

  func didTapRefreshButton() {
    ikaCatalog.refreshCatalog()
  }

  func didTapSettingsButton() {
    Haptics.generate(.selection)
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
        .onSet { _ in Haptics.generate(.soft) },
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
        .onSet { _ in Haptics.generate(.soft) },
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

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(IkaCatalog())
  }
}
