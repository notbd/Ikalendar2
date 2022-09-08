//
//  SettingsMainView.swift
//  Ikalendar2
//
//  Copyright (c) 2022 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SettingsMainView

/// The main page for App Settings.
struct SettingsMainView: View {
  @Environment(\.openURL) var openURL

  @EnvironmentObject var ikaStatus: IkaStatus
  @EnvironmentObject var ikaPreference: IkaPreference

  typealias Scoped = Constants.Styles.Settings.Main

  private var currLanguage: String {
    if Locale.current.identifier.starts(with: "en") { return "English" }
    if Locale.current.identifier.starts(with: "ja") { return "日本語" }
    if Locale.current.identifier.starts(with: "zh_Hans") { return "简体中文(beta)" }
    if Locale.current.identifier.starts(with: "zh_Hant") { return "繁體中文(beta)" }
    else { return "Unknown" }
  }

  var body: some View {
    NavigationView {
      // not using NavigationStack as of iOS 16 beta because of titleDisplayMode bug
      Form {
        Section(header: Text("Default Mode")) {
          rowDefaultGameMode
          rowDefaultBattleMode
        }

        Section(header: Text("Appearance")) {
          rowColorScheme
          rowAltStageImages
          rowAppIcon
        }

        Section(header: Text("Language")) {
          rowAppLanguage
        }

        Section {
          rowAbout
          rowCredits
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.large)
      .navigationBarItems(trailing: doneButton)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  // MARK: - Components ↓↓↓

  // MARK: - Default Mode Section

  private var rowDefaultGameMode: some View {
    HStack {
      Label(
        "Game",
        systemImage: Scoped.DEFAULT_GAME_MODE_SFSYMBOL)
        .symbolRenderingMode(.palette)
        .foregroundStyle(.primary, Color.accentColor)

      Spacer().frame(width: Scoped.DEFAULT_MODE_PICKER_SPACING)

      Picker(
        selection: $ikaPreference.defaultGameMode
          .onSet { _ in Haptics.generate(.selection) },
        label: Text("Default Game Mode"))
      {
        ForEach(GameMode.allCases) { gameMode in
          Text(gameMode.name.localizedStringKey())
            .tag(gameMode)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }

  private var rowDefaultBattleMode: some View {
    HStack {
      Label(
        "Battle",
        systemImage: Scoped.DEFAULT_BATTLE_MODE_SFSYMBOL)
        .symbolRenderingMode(.palette)
        .foregroundStyle(.primary, Color.accentColor)

      Spacer().frame(width: Scoped.DEFAULT_MODE_PICKER_SPACING)

      Picker(
        selection: $ikaPreference.defaultBattleMode
          .onSet { _ in Haptics.generate(.selection) },
        label: Text("Default Battle Mode"))
      {
        ForEach(BattleMode.allCases) { battleMode in
          Text(battleMode.shortName.localizedStringKey())
            .tag(battleMode)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .disabled(ikaPreference.defaultGameMode != .battle)
    }
  }

  // MARK: - Appearance Section

  private var rowColorScheme: some View {
    HStack {
      Label(
        "Color Scheme",
        systemImage: Scoped.COLOR_SCHEME_SFSYMBOL)

      Spacer()
        .frame(
          maxWidth: currLanguage == "English"
            ? Scoped.COLOR_SCHEME_PICKER_SPACING_en
            : Scoped.COLOR_SCHEME_PICKER_SPACING_ja)

      Picker(
        selection: $ikaPreference.appColorScheme
          .onSet { _ in Haptics.generate(.selection) },
        label: Text("App Color Scheme"))
      {
        ForEach(ColorSchemeManager.AppColorScheme.allCases) { appColorScheme in
          Text(appColorScheme.name.localizedStringKey())
            .tag(appColorScheme)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }

  private var rowAltStageImages: some View {
    Toggle(isOn: .constant(true)) {
      Label(
        "Alternative Stage Images",
        systemImage: Scoped.ALT_STAGE_IMG_SFSYMBOL)
    }
    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
  }

  private var rowAppIcon: some View {
    NavigationLink(destination: SettingsAppIconView()) {
      Label(
        "App Icon",
        systemImage: Scoped.APP_ICON_SFSYMBOL)
    }
  }

  // MARK: - Language Section

  private var rowAppLanguage: some View {
    Button {
      Haptics.generate(.selection)
      if let url = URL(string: UIApplication.openSettingsURLString) {
        openURL(url)
      }
    } label: {
      HStack {
        Label {
          Text("Preferred Language")
            .foregroundColor(.primary)
        }
        icon: {
          Image(systemName: Scoped.PREF_LANG_SFSYMBOL)
        }

        Spacer()

        Text(currLanguage)
          .foregroundColor(.secondary)

        Image(systemName: Scoped.PREF_LANG_JUMP_SFSYMBOL)
          .foregroundColor(.secondary)
      }
    }
  }

  // MARK: - Others Section

  private var rowAbout: some View {
    NavigationLink(destination: SettingsAboutView()) {
      Label(
        "About",
        systemImage: Scoped.ABOUT_SFSYMBOL)
    }
  }

  private var rowCredits: some View {
    NavigationLink(destination: SettingsAcknowledgementView()) {
      Label(
        "Credits",
        systemImage: Scoped.CREDITS_SFSYMBOL)
    }
  }

  // MARK: - Toolbar Buttons

  private var doneButton: some View {
    Button {
      Haptics.generate(.selection)
      ikaStatus.isSettingsPresented.toggle()
    } label: {
      Text("Done")
        .fontWeight(Scoped.DONE_BUTTON_FONT_WEIGHT)
    }
  }
}

// MARK: - SettingsMainView_Previews

struct SettingsMainView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMainView()
  }
}
