//
//  BattleRotationRow.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

// MARK: - BattleRotationRow

/// A row containing all the information of a battle rotation.
@MainActor
struct BattleRotationRow: View {
  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

  let rotation: BattleRotation
  let rowWidth: CGFloat

  private var rowType: RowType {
    if rotation.isCurrent(ikaTimePublisher.currentTime) { .now }
    else if rotation.isNext(ikaTimePublisher.currentTime) { .next }
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
          Scoped.CURRENT_PREFIX_STRING
        case .next:
          Scoped.NEXT_PREFIX_STRING
        case .other:
          nil
      }
    }
  }
}

// MARK: - BattleRotationHeader

/// The header of the battle rotation row.
struct BattleRotationHeader: View {
  typealias Scoped = Constants.Style.Rotation.Header

  @EnvironmentObject private var ikaTimePublisher: IkaTimePublisher

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
    HStack(spacing: Scoped.SPACING) {
      // skip if `prefixString` is nil (case .other)
      if let prefixString = rowType.prefixString {
        Text(prefixString.localizedStringKey)
          .ikaFont(
            .ika1,
            size: Scoped.PREFIX_FONT_SIZE,
            relativeTo: .title2)
          .foregroundStyle(Color.systemBackground)
          .padding(.horizontal, Scoped.PREFIX_PADDING_H)
          .background(Color.secondary)
          .cornerRadius(Scoped.PREFIX_FRAME_CORNER_RADIUS)
      }

      // Battle Time String
      Text("\(startTimeString) - \(endTimeString)")
        .scaledLimitedLine()
        .ikaFont(
          .ika2,
          size: Scoped.CONTENT_FONT_SIZE,
          relativeTo: .headline)
    }
  }
}

// MARK: - BattleRotationRow_Previews

struct BattleRotationRow_Previews: PreviewProvider {
  @State static private var modeSelection: BattleMode = .gachi

  static var previews: some View {
    NavigationView {
      GeometryReader { geo in
        List {
          Section {
            Picker("Mode", selection: $modeSelection) {
              ForEach(BattleMode.allCases) { battleMode in
                Text(battleMode.shortName)
                  .tag(battleMode)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
          }

          ForEach(0 ..< IkaMockData.getBattleRotations()[modeSelection]!.count, id: \.self)
          { index in
            BattleRotationRow(
              rotation: IkaMockData.getBattleRotations()[modeSelection]![index],
              rowWidth: geo.size.width)
          }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(modeSelection.name)
      }
    }
  }
}
