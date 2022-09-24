//
//  SettingsAdvancedView.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsAppearanceAdvancedView

struct SettingsAdvancedView: View {
  @EnvironmentObject var ikaStatus: IkaStatus
  @EnvironmentObject var ikaPreference: IkaPreference

  typealias Scoped = Constants.Styles.Settings.Advanced

  var body: some View {
    Form {
      Section(header: Text("Alternative Stage Images")) {
        rowAltStageImagesToggle
        rowAltStageImagesPreview
      }

      Section(header: Text("Bottom Toolbar Picker Positioning")) {
        rowBottomToolbarPositioningPicker
        rowBottomToolbarPositioningPreview
      }
    }
    .navigationTitle("Advanced Options")
    .navigationBarTitleDisplayMode(.inline)
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

  private var rowAltStageImagesPreview: some View {
    // placeholder
    Toggle(isOn: .constant(true)) {
      Label(
        "Alternative Stage Images",
        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

  private var rowBottomToolbarPositioningPicker: some View {
    // placeholder
    Toggle(isOn: .constant(true)) {
      Label(
        "Bottom Toolbar Picker Positioning",
        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

  private var rowBottomToolbarPositioningPreview: some View {
    // placeholder
    Toggle(isOn: .constant(true)) {
      Label(
        "Bottom Toolbar Picker Positioning",
        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }
}
