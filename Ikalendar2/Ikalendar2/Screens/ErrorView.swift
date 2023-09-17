//
//  ErrorView.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - ErrorView

/// The error view showing the error if occurs.
struct ErrorView: View {
  typealias Scoped = Constants.Style.Error

  @EnvironmentObject private var ikaCatalog: IkaCatalog

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
    VStack(alignment: .leading) {
      Text(error.title.localizedStringKey)
        .scaledLimitedLine()
        .if(Scoped.IF_USE_CUSTOM_FONT) {
          $0.fontIka(
            .ika2,
            size: Scoped.TITLE_CUSTOM_FONT_SIZE,
            relativeTo: .largeTitle)
        } else: {
          $0.font(.system(.largeTitle, design: .rounded))
        }
        .padding(.bottom, Scoped.TITLE_MESSAGE_SPACING)

      Text(error.message.localizedStringKey)
        .if(Scoped.IF_USE_CUSTOM_FONT) {
          $0.fontIka(
            .ika2,
            size: Scoped.MESSAGE_CUSTOM_FONT_SIZE,
            relativeTo: .body)
        } else: {
          $0.font(.system(.body, design: .rounded))
        }
    }
    .foregroundColor(.secondary)
  }

  private var errorImage: some View {
    Image("little-buddy")
      .antialiased(true)
      .resizable()
      .scaledToFit()
      .grayscale(0.9)
  }
}

// MARK: - ErrorView_Previews

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(error: .serverError(.badData))
  }
}
