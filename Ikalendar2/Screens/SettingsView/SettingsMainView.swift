//
//  SettingsMainView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SimpleHaptics
import SwiftUI

// MARK: - SettingsMainView

/// The main page for App Settings.
@MainActor
struct SettingsMainView: View {
  typealias Scoped = Constants.Style.Settings.Main

  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var currentLocale

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @EnvironmentObject private var ikaLog: IkaLog
  @EnvironmentObject private var ikaPreference: IkaPreference

  @State private var rowWidth: CGFloat = 390

  var body: some View {
    GeometryReader { geo in
      List {
        Section {
          rowDefaultGameMode
          rowDefaultBattleMode
        } header: {
          Text("Default Mode")
        } footer: {
          if !isHorizontalCompact {
            Text("Certain options only apply to smaller screen widths.")
              .font(.footnote)
          }
          else {
            EmptyView()
          }
        }

        Section {
          rowColorScheme
          rowAltAppIcon
          rowAdvancedOptions
        } header: { Text("Appearance") }

        Section {
          rowAppLanguage
        } header: { Text("Language") }

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
        Image(systemName: ikaPreference.preferredDefaultGameMode.sfSymbolNameSelected)
          .imageScale(.medium)
          .contentTransition(.symbolEffect(.replace.offUp))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }

      Spacer()

      Picker(
        selection: $ikaPreference.preferredDefaultGameMode,
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
          systemName: ikaPreference.preferredDefaultBattleMode.sfSymbolNameSelected)
          .imageScale(.medium)
          .contentTransition(.symbolEffect(.replace.offUp))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(
            ikaPreference.preferredDefaultGameMode != .battle || !isHorizontalCompact
              ? .secondary
              : ikaPreference.preferredDefaultBattleMode.themeColor)
      }

      Spacer()

      Picker(
        selection: $ikaPreference.preferredDefaultBattleMode,
        label: Text("Default Battle Mode"))
      {
        ForEach(BattleMode.allCases) { battleMode in
          Text(battleMode.shortName.localizedStringKey)
            .tag(battleMode)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
      .fixedSize()
      .disabled(ikaPreference.preferredDefaultGameMode != .battle || !isHorizontalCompact)
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
        Image(
          systemName: Scoped.COLOR_SCHEME_SFSYMBOL)
          .imageScale(.medium)
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

  @State private var rowAltAppIconSfSymbolBounce: Int = 0
  private var bounceTimer = Timer
    .publish(
      every: Constants.Config.Timer.bounceSignalInterval,
      tolerance: 0.1,
      on: .main,
      in: .common)
    .autoconnect()

  private var rowAltAppIcon: some View {
    NavigationLink(destination: SettingsAltAppIconView()) {
      Label {
        Text("App Icon")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: ikaPreference.preferredAppIcon.settingsMainSFSymbolName)
          .symbolEffect(.bounce, value: rowAltAppIconSfSymbolBounce)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
      .onReceive(bounceTimer) { _ in
        if !ikaLog.hasDiscoveredAltAppIcon { rowAltAppIconSfSymbolBounce += 1 }
      }
    }
  }

  private var rowAdvancedOptions: some View {
    let customizations = [
      ikaPreference.shouldMinimizeTabBar,
      ikaPreference.shouldUseAltStageImages,
    ]
    let customizedPercentage = Double(customizations.count(where: { $0 })) / Double(customizations.count)

    return NavigationLink(destination: SettingsAdvancedOptionsView()) {
      Label {
        Text("Advanced Options")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(
          systemName: Scoped.ADVANCED_OPTIONS_SFSYMBOL,
          variableValue: customizedPercentage)
          .imageScale(.medium)
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
            .imageScale(.medium)
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.accentColor)
        }

        Spacer()

        Text(currentLocale.toIkaLocale().description)
          .foregroundStyle(Color.secondary)

        Constants.Style.Global.EXTERNAL_LINK_JUMP_ICON
          .foregroundStyle(Color.secondary)
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
          .imageScale(.medium)
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
          .imageScale(.medium)
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
        .font(Scoped.DONE_BUTTON_FONT)
    }
  }
}

// MARK: - SettingsMainView_Previews

struct SettingsMainView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsMainView()
  }
}
