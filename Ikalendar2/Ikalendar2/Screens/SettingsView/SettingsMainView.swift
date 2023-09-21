//
//  SettingsMainView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsMainView

/// The main page for App Settings.
struct SettingsMainView: View {
  typealias Scoped = Constants.Style.Settings.Main

  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var currentLocale

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @EnvironmentObject private var ikaStatus: IkaStatus
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var rowWidth: CGFloat = 390

  var body: some View {
    NavigationView {
      // not using NavigationStack for Settings as of iOS 16 because of titleDisplayMode bug
      GeometryReader { geo in
        List {
          Section(header: Text("Default Mode")) {
            rowDefaultGameMode
            rowDefaultBattleMode
          }

          Section(header: Text("Appearance")) {
            rowColorScheme
            rowAltAppIcon
            rowAdvancedOptions
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
        .listStyle(.insetGrouped)
        .onChange(of: geo.size, initial: true) { _, newVal in
          rowWidth = newVal.width
        }
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }

  // MARK: - Default Mode Section

  private var rowDefaultGameMode: some View {
    HStack {
      Label {
        if rowWidth >= Scoped.DEFAULT_MODE_PICKER_NAME_SHOWED_THRESHOLD {
          Text("Game")
            .foregroundStyle(.primary)
        }
        else {
          Spacer()
        }
      } icon: {
        Image(systemName: ikaPreference.defaultGameMode.sfSymbolNameSelected)
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }

      Spacer()

      Picker(
        selection: $ikaPreference.defaultGameMode,
        label: Text("Default Game Mode"))
      {
        ForEach(GameMode.allCases) { gameMode in
          Text(gameMode.name.localizedStringKey)
            .tag(gameMode)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .fixedSize()
    }
  }

  private var rowDefaultBattleMode: some View {
    HStack {
      Label {
        if rowWidth >= Scoped.DEFAULT_MODE_PICKER_NAME_SHOWED_THRESHOLD {
          Text("Battle")
            .foregroundStyle(.primary)
        }
        else {
          Spacer()
        }
      } icon: {
        Image(
          systemName: ikaPreference.defaultGameMode != .battle || !isHorizontalCompact
            ? ikaPreference.defaultBattleMode.sfSymbolNameIdle
            : ikaPreference.defaultBattleMode.sfSymbolNameSelected)
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(
            ikaPreference.defaultGameMode != .battle || !isHorizontalCompact
              ? .secondary
              : Color.accentColor)
      }

      Spacer()

      Picker(
        selection: $ikaPreference.defaultBattleMode,
        label: Text("Default Battle Mode"))
      {
        ForEach(BattleMode.allCases) { battleMode in
          Text(battleMode.shortName.localizedStringKey)
            .tag(battleMode)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .fixedSize()
      .disabled(ikaPreference.defaultGameMode != .battle || !isHorizontalCompact)
    }
  }

  // MARK: - Appearance Section

  private var rowColorScheme: some View {
    HStack {
      Label {
        Text("Color Scheme")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: Scoped.COLOR_SCHEME_SFSYMBOL)
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }

      Spacer()

      Menu {
        Picker(
          selection: $ikaPreference.preferredAppColorScheme,
          label: EmptyView())
        {
          ForEach(IkaColorSchemeManager.PreferredColorScheme.allCases) { preferredColorScheme in
            Label(
              preferredColorScheme.name.localizedStringKey,
              systemImage: preferredColorScheme.sfSymbolName)
              .tag(preferredColorScheme)
          }
        }
      } label: {
        HStack {
          Image(systemName: ikaPreference.preferredAppColorScheme.sfSymbolName)
            .foregroundStyle(Color.secondary)

          Image(systemName: Scoped.COLOR_SCHEME_MENU_SFSYMBOL)
            .foregroundStyle(Color.tertiaryLabel)
        }
      }
    }
  }

  private var rowAltAppIcon: some View {
    let altAppIconStatusSFSymbolName = ikaPreference.preferredAppIcon.getSettingsSFSymbolName()

    return NavigationLink(destination: SettingsAltAppIconView()) {
      Label {
        Text("App Icon")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: altAppIconStatusSFSymbolName)
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  private var rowAdvancedOptions: some View {
    let customizations = [
      ikaPreference.ifSwapBottomToolbarPickers,
      ikaPreference.ifUseAltStageImages,
    ]
    let customizedPercentage = Double(customizations.filter { $0 }.count) / Double(customizations.count)

    return NavigationLink(destination: SettingsAdvancedOptionsView()) {
      Label {
        Text("Advanced Options")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(
          systemName: Scoped.ADVANCED_OPTIONS_SFSYMBOL,
          variableValue: customizedPercentage)
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  // MARK: - Language Section

  private var rowAppLanguage: some View {
    Button {
      guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
      SimpleHaptics.generateTask(.selection)
      openURL(url)
    } label: {
      HStack {
        Label {
          Text("Preferred Language")
            .foregroundStyle(Color.primary)
        }
        icon: {
          Image(systemName: currentLocale.toIkaLocale().sfSymbolName)
            .font(.subheadline)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.accentColor)
        }

        Spacer()

        Text(currentLocale.toIkaLocale().description)
          .foregroundStyle(Color.secondary)

        Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
      }
    }
  }

  // MARK: - Others Section

  private var rowAbout: some View {
    NavigationLink(destination: SettingsAboutView()) {
      Label {
        Text("About")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: Scoped.ABOUT_SFSYMBOL)
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  private var rowCredits: some View {
    NavigationLink(destination: SettingsCreditsView()) {
      Label {
        Text("Credits")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: Scoped.CREDITS_SFSYMBOL)
          .font(.subheadline)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  // MARK: - Toolbar Buttons

  private var doneButton: some View {
    Button {
      dismiss()
    } label: {
      Text("Done")
//        .fontWeight(Scoped.DONE_BUTTON_FONT_WEIGHT)
        .font(.headline)
    }
  }
}

// MARK: - SettingsMainView_Previews

struct SettingsMainView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMainView()
  }
}
