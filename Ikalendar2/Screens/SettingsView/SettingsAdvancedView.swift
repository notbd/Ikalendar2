//
//  SettingsAdvancedView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsAppearanceAdvancedView

struct SettingsAdvancedView: View {
  @EnvironmentObject var ikaStatus: IkaStatus
  @EnvironmentObject var ikaPreference: IkaPreference

  @State private var ifToolbarPreviewPresented = false

  typealias Scoped = Constants.Styles.Settings.Advanced

//  let battleRotationExample =
//    IkaMockData.getBattleRotation(rule: BattleRule.allCases.randomElement()!)
//  let salmonRotationExample = IkaMockData.getSalmonRotation()

  var body: some View {
    Form {
      Section(header: Text("Alternative Stage Images")) {
        rowAltStageImagesToggle
      }

      Section(header: Text("Bottom Toolbar Picker Positioning")) {
        rowBottomToolbarPositioningPicker
        rowBottomToolbarPositioningPreview
      }
    }
    .navigationTitle("Advanced Options")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $ifToolbarPreviewPresented) {
      Text("Hello World!")
        .presentationDetents([.fraction(0.1)])
    }
  }

  private var rowAltStageImagesToggle: some View {
    // placeholder
    // TODO: add all view content
    Toggle(isOn: .constant(true)) {
      Label(
        "Alternative Stage Images",
        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

//  private var rowAltStageImagesPreview: some View {
//    // placeholder
//    Toggle(isOn: .constant(true)) {
//      Label(
//        "Alternative Stage Images",
//        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
//    }
//    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
//  }

  private var rowBottomToolbarPositioningPicker: some View {
    // placeholder
    Toggle(isOn: $ikaPreference.ifReverseToolbarPickers) {
      Label(
        "Reverse Toolbar Pickers",
        systemImage: Scoped.BOTTOM_TOOLBAR_PICKER_POSITIONING_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
    .onChange(of: ikaPreference.ifReverseToolbarPickers) { _ in
      /// use _isOn here..
      ifToolbarPreviewPresented = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        ifToolbarPreviewPresented = false
      }
    }
  }

  private var rowBottomToolbarPositioningPreview: some View {
    // placeholder
    Toggle(isOn: .constant(true)) {
      Label(
        "Bottom Toolbar Picker Positioning",
        systemImage: Scoped.BOTTOM_TOOLBAR_PICKER_POSITIONING_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }
}
