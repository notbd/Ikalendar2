//
//  SalmonRotationRow.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - SalmonRotationRow

/// A row containing all the information of a salmon rotation.
struct SalmonRotationRow: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @EnvironmentObject var ikaTimeManager: IkaTimeManager

  var rotation: SalmonRotation
  var index: Int
  var rowWidth: CGFloat

  var isCurrent: Bool { rotation.isCurrent(currentTime: ikaTimeManager.currentTime) }

  var rowType: RowType {
    typealias Scoped = Constants.Styles.Rotation.Salmon.Header

    if index == 0 {
      return isCurrent ? .first(.active) : .first(.idle)
    }
    else if index == 1 {
      return isCurrent ? .second(.active) : .second(.idle)
    }
    else {
      return .other
    }
  }

  var body: some View {
    Section {
      SalmonRotationCell(
        rotation: rotation,
        rowWidth: rowWidth)
    } header: {
      switch rowType {
      case .first,
           .second:
        SalmonRotationHeader(prefixString: rowType.prefixString)
      case .other:
        EmptyView()
      }
    }
  }
}

// MARK: SalmonRotationRow.RowType

extension SalmonRotationRow {
  enum RowType: Equatable {
    typealias Scoped = Constants.Styles.Rotation.Salmon.Header

    case first(SalmonCurrentStatus)
    case second(SalmonCurrentStatus)
    case other

    enum SalmonCurrentStatus {
      case active
      case idle
    }

    var prefixString: String {
      switch self {
      case .first(let currentStatus):
        switch currentStatus {
        case .active:
          return Scoped.FIRST_PREFIX_STRINGS.active
        case .idle:
          return Scoped.FIRST_PREFIX_STRINGS.idle
        }

      case .second(let currentStatus):
        switch currentStatus {
        case .active:
          return Scoped.SECOND_PREFIX_STRINGS.active
        case .idle:
          return Scoped.SECOND_PREFIX_STRINGS.idle
        }

      case .other:
        return ""
      }
    }
  }
}

// MARK: - SalmonRotationHeader

/// The header of the salmon rotation row.
struct SalmonRotationHeader: View {
  typealias Scoped = Constants.Styles.Rotation.Salmon.Header

  @Environment(\.colorScheme) var deviceColorScheme

  var prefixString: String

  var body: some View {
    Text(prefixString.localizedStringKey())
      .fontIka(.ika1, size: Scoped.FONT_SIZE)
      .foregroundColor(Color.systemBackground)
      .padding(.horizontal, Scoped.PREFIX_PADDING)
      .background(Color.secondary)
      .cornerRadius(Scoped.PREFIX_FRAME_CORNER_RADIUS)
  }
}

// MARK: - SalmonRotationRow_Previews

struct SalmonRotationRow_Previews: PreviewProvider {
  static var previews: some View {
    SalmonRotationRow(
      rotation: IkaMockData.getSalmonRotation(),
      index: 0,
      rowWidth: 390)
  }
}
