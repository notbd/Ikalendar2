//
//  NavViewNew.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - NavViewNew

struct NavViewNew: View {
  @EnvironmentObject var ikaCatalog: IkaCatalog
  @EnvironmentObject var ikaStatus: IkaStatus

  typealias Scoped = Constants.Styles.ToolbarButton

  var body: some View {
    NavigationStack {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        .navigationTitle("Nav Stack")
        .toolbar {
          // MARK: refresh button

          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { }) {
              Image(systemName: "arrow.triangle.2.circlepath")
                .foregroundColor(.primary)
                .font(Scoped.SFSYMBOL_FONT)
                .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
                .frame(width: Scoped.SILHOUETTE_SIDE, height: Scoped.SILHOUETTE_SIDE)
                .silhouetteFrame(cornerRadius: Scoped.SILHOUETTE_CORNER_RADIUS)
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { }) {
              Image(systemName: "gear")
                .foregroundColor(.primary)
                .font(Scoped.SFSYMBOL_FONT)
                .shadow(radius: Constants.Styles.Global.SHADOW_RADIUS)
                .frame(width: Scoped.SILHOUETTE_SIDE, height: Scoped.SILHOUETTE_SIDE)
                .silhouetteFrame(cornerRadius: Scoped.SILHOUETTE_CORNER_RADIUS)
            }
          }

          ToolbarItemGroup(placement: .bottomBar) {
            // MARK: game mode button

            ToolbarGameModeSwitchButton()

            Spacer()

            if ikaStatus.gameModeSelection == .battle {
              // MARK: battle mode picker

              ToolbarBattleModePicker()
            }
          }
        }
    }
  }
}

// MARK: - NavViewNew_Previews

struct NavViewNew_Previews: PreviewProvider {
  static var previews: some View {
    NavViewNew()
  }
}
