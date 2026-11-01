//
//  RotationHeaderPrefix.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import IkalendarKit
import SwiftUI

// MARK: - RotationHeaderPrefix

/// The gray glass pill that leads a rotation row header ("Now:", "Next:", "Open!", "Soon:").
struct RotationHeaderPrefix: View {
  typealias Scoped = Constants.Style.Rotation.Header

  let text: String

  var body: some View {
    Text(text.localizedStringKey)
      .ikaFont(
        .ika1,
        size: Scoped.prefixFontSize,
        relativeTo: .title2)
      .foregroundStyle(Color.systemBackground)
      .padding(.horizontal, Scoped.prefixPaddingH)
      .adaptiveGlassEffect(
        tint: .gray,
        in: .rect(cornerRadius: Scoped.prefixFrameCornerRadius))
  }

  init(_ text: String) {
    self.text = text
  }
}
