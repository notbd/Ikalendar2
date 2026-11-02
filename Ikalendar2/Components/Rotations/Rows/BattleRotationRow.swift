//
//  BattleRotationRow.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationRow

/// A row containing all the information of a battle rotation.
struct BattleRotationRow: View {
  @Environment(IkaClock.self) private var ikaClock

  let rotation: BattleRotation
  let rowWidth: CGFloat

  private var rowType: RowType {
    if rotation.isCurrent(ikaClock.currentTime) { .now }
    else if rotation.isNext(ikaClock.currentTime) { .next }
    else { .other }
  }

  var body: some View {
    Section {
      BattleRotationCell(
        type: rowType == .now ? .primary : .secondary,
        rotation: rotation,
        rowWidth: rowWidth)
    } header: {
      BattleRotationHeader(
        rotation: rotation,
        rowType: rowType)
    }
  }
}

// MARK: BattleRotationRow.RowType

extension BattleRotationRow {
  enum RowType {
    typealias Scoped = Constants.Style.Rotation.Header.Battle

    case now
    case next
    case other

    var prefixString: String? {
      switch self {
        case .now:
          Scoped.currentPrefixString
        case .next:
          Scoped.nextPrefixString
        case .other:
          nil
      }
    }
  }
}

// MARK: - BattleRotationHeader

/// The header of the battle rotation row.
private struct BattleRotationHeader: View {
  typealias Scoped = Constants.Style.Rotation.Header

  let rotation: BattleRotation
  let rowType: BattleRotationRow.RowType

  private var startTimeString: String {
    let shouldIncludeDate = Calendar.current.isDateInYesterday(rotation.startTime) ||
      Calendar.current.isDateInTomorrow(rotation.startTime)

    return rotation.startTime.toBattleTimeString(shouldIncludeDate: shouldIncludeDate)
  }

  private var endTimeString: String {
    let shouldIncludeDate = (
      Calendar.current.isDateInYesterday(rotation.startTime) &&
        Calendar.current.isDateInToday(rotation.endTime)) ||
      (
        Calendar.current.isDateInToday(rotation.startTime) &&
          Calendar.current.isDateInTomorrow(rotation.endTime))

    return rotation.endTime.toBattleTimeString(shouldIncludeDate: shouldIncludeDate)
  }

  var body: some View {
    HStack(spacing: Scoped.spacing) {
      if let prefixString = rowType.prefixString {
        RotationHeaderPrefix(prefixString)
      }

      Text("\(startTimeString) - \(endTimeString)")
        .scaledLimitedLine()
        .ikaFont(
          .ika2,
          size: Scoped.contentFontSize,
          relativeTo: .headline)
    }
  }
}

#Preview {
  @Previewable @State var modeSelection: BattleMode = .gachi
  // generated once, so switching modes does not reshuffle the stages
  @Previewable @State var rotations: BattleRotationDict = IkaMockData.makeBattleRotations()

  NavigationStack {
    GeometryReader { geo in
      List {
        Section {
          Picker("Mode", selection: $modeSelection) {
            ForEach(BattleMode.allCases) { battleMode in
              Text(battleMode.shortName)
                .tag(battleMode)
            }
          }
          .pickerStyle(.segmented)
        }

        ForEach(rotations[modeSelection] ?? []) { rotation in
          BattleRotationRow(
            rotation: rotation,
            rowWidth: geo.size.width)
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle(modeSelection.name)
    }
  }
  .ikaPreviewEnvironment()
}
