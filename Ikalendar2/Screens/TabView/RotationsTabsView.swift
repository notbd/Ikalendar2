//
//  RotationsTabsView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

struct RotationsTabsView: View {
  @Environment(IkaCatalog.self) private var ikaCatalog
  @Environment(IkaStatus.self) private var ikaStatus

  @EnvironmentObject private var ikaPreference: IkaPreference

  var body: some View {
    @Bindable var ikaStatus = ikaStatus

    TabView(selection: $ikaStatus.currentFlatMode) {
      ForEach(FlatMode.allCases) { flatMode in
        Tab(
          flatMode.shortName.localizedStringKey,
          systemImage: flatMode.sfSymbolNameSelected,
          value: flatMode)
        {
          NavigationStack {
            RotationsTabView(adoptedFlatMode: flatMode)
              .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                  ToolbarSettingsButton()
                }
              }
          }
        }
      }
    }
    .tabBarMinimizeBehavior(.onScrollDown)
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
}
