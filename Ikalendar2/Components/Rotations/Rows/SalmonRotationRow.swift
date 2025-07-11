//
//  SalmonRotationRow.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import IkalendarKit
import SwiftUI

// MARK: - SalmonRotationRow

/// A row containing all the information of a salmon rotation.
@MainActor
struct SalmonRotationRow: View {
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let rotation: SalmonRotation
  let index: Int
  let rowWidth: CGFloat

  private var rowType: RowType {
    // expired rotations already filtered out, so index will reflect truth
    switch index {
      case 0:
        rotation.isFuture(ikaTimePublisher.currentTime) ? .first(.pending) : .first(.active)
      case 1:
        .second
      default:
        .other
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
          SalmonRotationHeader(
            rotation: rotation,
            rowType: rowType)

        case .other:
          EmptyView()
      }
    }
  }
}

// MARK: SalmonRotationRow.RowType

extension SalmonRotationRow {
  enum RowType: Equatable {
    typealias Scoped = Constants.Style.Rotation.Header.Salmon

    case first(SalmonFirstRotationStatus)
    case second
    case other

    enum SalmonFirstRotationStatus {
      case pending
      case active
    }

    var prefixString: String? {
      switch self {
        case .first(let currentStatus):
          switch currentStatus {
            case .pending:
              Scoped.FIRST_PREFIX_STRINGS.pending
            case .active:
              Scoped.FIRST_PREFIX_STRINGS.active
          }

        case .second:
          Scoped.SECOND_PREFIX_STRING

        case .other:
          nil
      }
    }
  }
}

// MARK: - SalmonRotationHeader

/// The header of the salmon rotation row.
struct SalmonRotationHeader: View {
  typealias Scoped = Constants.Style.Rotation.Header

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let rotation: SalmonRotation
  let rowType: SalmonRotationRow.RowType

  var body: some View {
    HStack {
      // can force unwrap `prefixString` here because .other row type will not have header
      Text(rowType.prefixString!.localizedStringKey)
        .ikaFont(
          .ika1,
          size: Scoped.PREFIX_FONT_SIZE,
          relativeTo: .title2)
        .foregroundStyle(Color.systemBackground)
        .padding(.horizontal, Scoped.PREFIX_PADDING_H)
        .background(Color.secondary)
        .cornerRadius(Scoped.PREFIX_FRAME_CORNER_RADIUS)

      Spacer()

      // Time Until String (if first rotation pending)
      if
        case .first(let currentStatus) = rowType,
        currentStatus == .pending
      {
        Text(ikaTimePublisher.currentTime.toTimeUntilStringKey(until: rotation.startTime))
          .contentTransition(.numericText(countsDown: true))
          .animation(.snappy, value: ikaTimePublisher.currentTime)
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.CONTENT_FONT_SIZE,
            relativeTo: .headline)
      }
    }
    .animation(.default, value: rowType)
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
