//
//  ToolbarGameModeSwitchButton.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - ToolbarGameModeSwitchButton

/// A game mode switch button in the toolbar.
struct ToolbarGameModeSwitchButton: View {
  typealias Scoped = Constants.Style.ToolbarButton

  @EnvironmentObject private var ikaStatus: IkaStatus

  var body: some View {
    Menu {
      Picker(
        selection: $ikaStatus.gameModeSelection
          .onSet { _ in SimpleHaptics.generateTask(.warning) },
        label: Text("Game Mode"))
      {
        ForEach(GameMode.allCases) { gameMode in
          Label(
            gameMode.name.localizedStringKey,
            systemImage: ikaStatus.gameModeSelection == gameMode
              ? gameMode.sfSymbolNameSelected
              : gameMode.sfSymbolNameIdle)
            .tag(gameMode)
        }
      }
    }
    label: {
      Label(
        "Game Mode Switch",
        systemImage: Scoped.GAME_MODE_SWITCH_SFSYMBOL)
        .font(Scoped.SFSYMBOL_FONT_SIZE_SMALL)
        .foregroundColor(Color.primary)
        .shadow(radius: Constants.Style.Global.SHADOW_RADIUS)
        .tappableAreaFrame()
    }
    .onTapGesture {
      SimpleHaptics.generateTask(.selection)
    }
  }
}

// MARK: - ToolbarGameModeSwitchButton_Previews

struct ToolbarGameModeSwitchButton_Previews: PreviewProvider {
  static var previews: some View {
    ToolbarGameModeSwitchButton()
      .environmentObject(IkaCatalog.shared)
  }
}
