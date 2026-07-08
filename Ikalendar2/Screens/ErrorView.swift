//
//  ErrorView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ErrorView

/// The error view showing the error if occurs.
struct ErrorView: View {
  typealias Scoped = Constants.Style.Error

  @Environment(IkaCatalog.self) private var ikaCatalog

  let error: IkaError

  var body: some View {
    GeometryReader { geo in
      ScrollView {
        VStack {
          Spacer()
            .frame(height: geo.size.height * Scoped.errorSectionPaddingTopHeightRatio)

          errorText
            .hAlignment(.leading)

          Spacer()
            .frame(height: geo.size.height * Scoped.errorSectionSpacingHeightRatio)

          errorImage
            .frame(height: geo.size.height * Scoped.errorImgHeightRatio)
            .hAlignment(.leading)
        }
        .padding(.horizontal)
      }
    }
  }

  private var errorText: some View {
    VStack(
      alignment: .leading,
      spacing: 0)
    {
      Text(error.title.localizedStringKey)
        .scaledLimitedLine()
        .if(Scoped.shouldUseCustomFont) {
          $0
            .ikaFont(
              .ika2,
              size: Scoped.titleCustomFontSize,
              relativeTo: .largeTitle)
        } else: {
          $0.font(.system(.largeTitle, design: .rounded))
        }

      Spacer()
        .frame(height: Scoped.textSectionSpacing)

      Text(error.message.localizedStringKey)
        .lineSpacing(Scoped.messageLineSpacing)
        .if(Scoped.shouldUseCustomFont) {
          $0
            .ikaFont(
              .ika2,
              size: Scoped.messageCustomFontSize,
              relativeTo: .body)
        } else: {
          $0.font(.system(.body, design: .rounded))
        }
    }
    .foregroundStyle(Color.secondary)
  }

  private var errorImage: some View {
    Image(.juddMemCake)
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .saturation(0.4)
  }
}

#Preview("Server Error") {
  ErrorView(error: .serverError(.badData))
    .ikaPreviewEnvironment()
}

#Preview("Connection Error") {
  ErrorView(error: .connectionError)
    .ikaPreviewEnvironment()
}
