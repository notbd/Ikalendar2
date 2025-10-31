//
//  AutoLoadingOverlay.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - AutoLoadingOverlay

@MainActor
struct AutoLoadingOverlay: View {
  typealias Scoped = Constants.Style.Overlay.AutoLoading

  @Environment(IkaCatalog.self) private var ikaCatalog

  @Namespace private var ns

  var body: some View {
    GlassEffectContainer(spacing: Scoped.GLASS_EFFECT_CONTAINER_SPACING) {
      HStack {
        Group {
          Image(systemName: iconName)
            .symbolEffect(
              .rotate.byLayer,
              options: .repeat(.periodic(delay: 0.2)),
              isActive: ikaCatalog.autoLoadStatus == .autoLoading)
            .contentTransition(.symbolEffect(.replace.magic(fallback: .replace.byLayer)))
            .font(Scoped.SFSYMBOL_FONT)
            .frame(
              width: Scoped.FRAME_SIDE,
              height: Scoped.FRAME_SIDE)
            .glassEffect(
              .regular.interactive(),
              in: .rect(cornerRadius: Scoped.FRAME_CORNER_RADIUS))
            .glassEffectID("icon", in: ns)

          if ikaCatalog.autoLoadDelayedIdleStatus == .autoLoading {
            Text(Scoped.SUBTITLE.localizedStringKey)
              .font(Scoped.SUBTITLE_FONT)
              .padding(.horizontal, Scoped.SUBTITLE_PADDING_H)
              .frame(height: Scoped.FRAME_SIDE)
              .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Scoped.FRAME_CORNER_RADIUS))
              .glassEffectID("subtitle", in: ns)
          }
        }
        .foregroundStyle(Color.primary)
        .glassEffectTransition(.matchedGeometry)
      }
      .padding()
    }

    .opacity(ikaCatalog.autoLoadStatus == .idle ? 0 : 1)
    .transition(.scale.combined(with: .opacity))
    .animation(
      .bouncy,
      value: ikaCatalog.autoLoadStatus)
  }

  private var iconName: String {
    switch ikaCatalog.autoLoadDelayedIdleStatus {
      case .autoLoading:
        Scoped.LOADING_SFSYMBOL

      case .autoLoaded(let loadedStatus):
        switch loadedStatus {
          case .success:
            Scoped.LOADED_SUCCESS_SFSYMBOL
          case .failure:
            Scoped.LOADED_FAILURE_SFSYMBOL
        }

      case .idle:
        Scoped.LOADING_SFSYMBOL
    }
  }
}

// MARK: - AutoLoadingOverlay_Previews

struct AutoLoadingOverlay_Previews: PreviewProvider {
  static var previews: some View {
    AutoLoadingOverlay()
  }
}
