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
          Spacer()
          HStack {
            Spacer()
            ErrorViewContent(
              error: error,
              maxWidth: geo.size.width * Scoped.CONTENT_WIDTH_RATIO)
            Spacer()
          }
          Spacer()
        }
        .listRowBackground(Color.clear)
      }
    }
  }
}

// MARK: - ErrorViewContent

struct ErrorViewContent: View {
  typealias Scoped = Constants.Styles.Error

  var error: IkaError
  var maxWidth: CGFloat

  var body: some View {
    VStack(alignment: .leading) {
      Text(error.title)
        .scaledLimitedLine()
        .if(Scoped.IF_USE_CUSTOM_FONT) {
          $0.fontIka(.ika1, size: Scoped.TITLE_CUSTOM_FONT_SIZE, relativeTo: .largeTitle)
        } else: {
          $0.font(.system(.largeTitle, design: .rounded))
        }

      Text(error.message)
        .if(Scoped.IF_USE_CUSTOM_FONT) {
          $0.fontIka(.ika1, size: Scoped.MESSAGE_CUSTOM_FONT_SIZE, relativeTo: .caption)
        } else: {
          $0.font(.system(.caption, design: .rounded))
        }
    }
    .foregroundColor(.secondary)
    .frame(maxWidth: maxWidth)
  }
}

// MARK: - ErrorView_Previews

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(error: .serverError(.badData))
  }
}
