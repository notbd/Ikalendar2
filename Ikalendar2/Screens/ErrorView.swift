//
//  ErrorView.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ErrorView

/// The error view showing the error if occurs.
@MainActor
struct ErrorView: View {
  typealias Scoped = Constants.Style.Error

  @Environment(IkaCatalog.self) private var ikaCatalog

  let error: IkaError

  var body: some View {
    GeometryReader { geo in
      ScrollView {
        VStack {
          Spacer()
            .frame(height: geo.size.height * Scoped.ERROR_SECTION_PADDING_TOP_HEIGHT_RATIO)

          errorText
            .hAlignment(.leading)

          Spacer()
            .frame(height: geo.size.height * Scoped.ERROR_SECTION_SPACING_HEIGHT_RATIO)

          errorImage
            .frame(height: geo.size.height * Scoped.ERROR_IMG_HEIGHT_RATIO)
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
        .if(Scoped.IF_USE_CUSTOM_FONT) {
          $0
            .ikaFont(
              .ika2,
              size: Scoped.TITLE_CUSTOM_FONT_SIZE,
              relativeTo: .largeTitle)
        } else: {
          $0.font(.system(.largeTitle, design: .rounded))
        }

      Spacer()
        .frame(height: Scoped.TEXT_SECTION_SPACING)

      Text(error.message.localizedStringKey)
        .lineSpacing(Scoped.MESSAGE_LINE_SPACING)
        .if(Scoped.IF_USE_CUSTOM_FONT) {
          $0
            .ikaFont(
              .ika2,
              size: Scoped.MESSAGE_CUSTOM_FONT_SIZE,
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

// MARK: - ErrorView_Previews

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(error: .serverError(.badData))
  }
}
