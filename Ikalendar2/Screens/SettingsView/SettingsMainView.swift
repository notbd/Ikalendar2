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
struct SettingsMainView: View {
  typealias Scoped = Constants.Style.Settings.Main

  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var currentLocale

  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  private var isHorizontalCompact: Bool { horizontalSizeClass == .compact }

  @Environment(IkaDiscoveryLog.self) private var ikaDiscoveryLog
  @Environment(IkaPreference.self) private var ikaPreference

  @State private var rowWidth: CGFloat = 390

  var body: some View {
    GeometryReader { geo in
      List {
        Section {
          if isHorizontalCompact {
            rowDefaultTab
          }
          else {
            rowDefaultGameMode
            rowDefaultBattleMode
          }
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
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) { closeButton }
      }
      .listStyle(.insetGrouped)
      .onChange(of: geo.size, initial: true) { _, newVal in
        rowWidth = newVal.width
      }
    }
  }

  // MARK: - Default Mode Section

  private var rowDefaultTab: some View {
    @Bindable var ikaPreference = ikaPreference
    return Picker(
      selection: $ikaPreference.preferredDefaultFlatMode,
      label: Label {
        Text("Default Tab")
          .foregroundStyle(.primary)
      } icon: {
        Image(systemName: ikaPreference.preferredDefaultFlatMode.sfSymbolNameSelected)
          .imageScale(.medium)
          .contentTransition(.symbolEffect(.replace.offUp))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(ikaPreference.preferredDefaultFlatMode.themeColor)
      })
    {
      ForEach(FlatMode.allCases) { flatMode in
        Text(flatMode.name.localizedStringKey)
          .tag(flatMode)
      }
    }
  }

  private var rowDefaultGameMode: some View {
    @Bindable var ikaPreference = ikaPreference
    return HStack {
      Label {
        if !isHorizontalCompact {
          Text("Default Game Mode")
            .foregroundStyle(.primary)
        }
        else if rowWidth >= Scoped.defaultModePickerNameShowedThreshold {
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
      .pickerStyle(.segmented)
      .fixedSize()
    }
  }

  private var rowDefaultBattleMode: some View {
    @Bindable var ikaPreference = ikaPreference
    return HStack {
      Label {
        if !isHorizontalCompact {
          Text("Default Battle Mode")
            .foregroundStyle(.primary)
        }
        else if rowWidth >= Scoped.defaultModePickerNameShowedThreshold {
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
      .pickerStyle(.segmented)
      .fixedSize()
      .disabled(ikaPreference.preferredDefaultGameMode != .battle || !isHorizontalCompact)
    }
  }

  // MARK: - Appearance Section

  private var rowColorScheme: some View {
    @Bindable var ikaPreference = ikaPreference
    return Picker(
      selection: $ikaPreference.preferredAppColorScheme,
      label: Label {
        Text("Color Scheme")
          .foregroundStyle(.primary)
      } icon: {
        Image(
          systemName: Scoped.colorSchemeSFSymbol)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      })
    {
      ForEach(IkaColorSchemeManager.PreferredColorScheme.allCases) { preferredColorScheme in
        Label(
          preferredColorScheme.name.localizedStringKey,
          systemImage: preferredColorScheme.sfSymbolName)
          .tag(preferredColorScheme)
      }
    }
  }

  private var rowAltAppIcon: some View {
    NavigationLink(destination: SettingsAltAppIconView()) {
      Label {
        Text("App Icon")
          .foregroundStyle(.primary)
      }
      icon: {
        Image(systemName: ikaPreference.preferredAppIcon.settingsMainSFSymbolName)
          .iconNudge(isActive: !ikaDiscoveryLog.hasDiscoveredAltAppIcon)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
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
          systemName: Scoped.advancedOptionsSFSymbol,
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

        Constants.Style.Global.externalLinkJumpIcon
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
        Image(systemName: Scoped.aboutSFSymbol)
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
        Image(systemName: Scoped.creditsSFSymbol)
          .imageScale(.medium)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(Color.accentColor)
      }
    }
  }

  // MARK: - Toolbar Buttons

  private var closeButton: some View {
    Button(
      "Done",
      systemImage: "checkmark",
      role: .close)
    {
      dismiss()
    }
  }
}

#Preview {
  SettingsMainView()
}
