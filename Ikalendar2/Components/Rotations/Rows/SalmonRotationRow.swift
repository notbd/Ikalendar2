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
struct SalmonRotationRow: View {
  @Environment(IkaClock.self) private var ikaClock

  let rotation: SalmonRotation
  let index: Int
  let rowWidth: CGFloat

  private var rowType: RowType {
    // expired rotations already filtered out, so index will reflect truth
    switch index {
      case 0:
        rotation.isFuture(ikaClock.currentTime) ? .first(.pending) : .first(.active)
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
              Scoped.firstPrefixStrings.pending
            case .active:
              Scoped.firstPrefixStrings.active
          }

        case .second:
          Scoped.secondPrefixString

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

  @Environment(IkaClock.self) private var ikaClock

  @Environment(\.colorScheme) private var colorScheme
  private var colorSchemeAwareGlass: Glass {
    colorScheme == .dark ? .clear : .regular
  }

  let rotation: SalmonRotation
  let rowType: SalmonRotationRow.RowType

  var body: some View {
    HStack {
      // can force unwrap `prefixString` here because .other row type will not have header
      Text(rowType.prefixString!.localizedStringKey)
        .ikaFont(
          .ika1,
          size: Scoped.prefixFontSize,
          relativeTo: .title2)
        .foregroundStyle(Color.systemBackground)
        .padding(.horizontal, Scoped.prefixPaddingH)
        .glassEffect(
          colorSchemeAwareGlass.tint(.secondary).interactive(),
          in: .rect(cornerRadius: Scoped.prefixFrameCornerRadius))

      Spacer()

      // Time Until String (if first rotation pending)
      if
        case .first(let currentStatus) = rowType,
        currentStatus == .pending
      {
        Text(ikaClock.currentTime.toTimeUntilStringKey(until: rotation.startTime))
          .contentTransition(.numericText(countsDown: true))
          .animation(.snappy, value: ikaClock.currentTime)
          .scaledLimitedLine()
          .ikaFont(
            .ika2,
            size: Scoped.contentFontSize,
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
