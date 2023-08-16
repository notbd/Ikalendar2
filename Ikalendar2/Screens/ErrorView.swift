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
  typealias Scoped = Constants.Styles.Error

  var error: IkaError

  var body: some View {
    GeometryReader { geo in
      List {
        Section {
          errorText
            .padding(.top, geo.size.height * 0.2)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

        Section {
          errorImage
            .frame(width: geo.size.width * 0.15) // adjust image width
            .frame(maxWidth: .infinity, alignment: .leading) // horizontally align the image
            .padding(.top, geo.size.height * 0.05)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
      }
    }
  }

  private var errorText: some View {
    VStack(alignment: .leading) {
      Text(error.title.localizedStringKey())
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

      Text(error.message.localizedStringKey())
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
      .resizable()
      .scaledToFit()
      .grayscale(1.0)
  }
}

// MARK: - ErrorView_Previews

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(error: .serverError(.badData))
  }
}
