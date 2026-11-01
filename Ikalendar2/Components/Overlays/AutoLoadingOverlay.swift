//
//  AutoLoadingOverlay.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - AutoLoadingOverlay

/// The little toast that reports auto-load activity and its outcome.
struct AutoLoadingOverlay: View {
  typealias Scoped = Constants.Style.Overlay.AutoLoading

  @Environment(IkaCatalog.self) private var ikaCatalog

  @Namespace private var ns

  var body: some View {
    GlassEffectContainer(spacing: Scoped.glassEffectContainerSpacing) {
      HStack {
        Group {
          Image(systemName: iconName)
            .symbolEffect(
              .rotate.byLayer,
              options: .repeat(.periodic(delay: 0.2)),
              isActive: ikaCatalog.autoLoadStatus == .autoLoading)
            .contentTransition(.symbolEffect(.replace.magic(fallback: .replace.byLayer)))
            .font(Scoped.symbolFont)
            .frame(
              width: Scoped.frameSide,
              height: Scoped.frameSide)
            .glassEffect(
              .regular.interactive(),
              in: .rect(cornerRadius: Scoped.frameCornerRadius))
            .glassEffectID("icon", in: ns)

          if ikaCatalog.autoLoadDisplayStatus == .autoLoading {
            Text(Scoped.subtitle.localizedStringKey)
              .font(Scoped.subtitleFont)
              .padding(.horizontal, Scoped.subtitlePaddingH)
              .frame(height: Scoped.frameSide)
              .glassEffect(
                .regular.interactive(),
                in: .rect(cornerRadius: Scoped.frameCornerRadius))
              .glassEffectID("subtitle", in: ns)
          }
        }
        .foregroundStyle(Color.primary)
        .glassEffectTransition(.matchedGeometry)
      }
      .padding()
    }
    .opacity(ikaCatalog.autoLoadStatus == .idle ? 0 : 1)
    .animation(
      .bouncy,
      value: ikaCatalog.autoLoadStatus)
  }

  private var iconName: String {
    switch ikaCatalog.autoLoadDisplayStatus {
      case .autoLoading:
        Scoped.loadingSFSymbol

      case .autoLoaded(let loadedStatus):
        switch loadedStatus {
          case .success:
            Scoped.loadedSuccessSFSymbol
          case .failure:
            Scoped.loadedFailureSFSymbol
        }

      case .idle:
        Scoped.loadingSFSymbol
    }
  }
}

#Preview {
  AutoLoadingOverlay()
    .ikaPreviewEnvironment()
}
