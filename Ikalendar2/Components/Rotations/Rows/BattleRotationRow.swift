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
struct BattleRotationHeader: View {
  typealias Scoped = Constants.Style.Rotation.Header

  @Environment(IkaClock.self) private var ikaClock

  @Environment(\.colorScheme) private var colorScheme
  private var colorSchemeAwareGlass: Glass {
    colorScheme == .dark ? .clear : .regular
  }

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
      // skip if `prefixString` is nil (case .other)
      if let prefixString = rowType.prefixString {
        Text(prefixString.localizedStringKey)
          .ikaFont(
            .ika1,
            size: Scoped.prefixFontSize,
            relativeTo: .title2)
          .foregroundStyle(Color.systemBackground)
          .padding(.horizontal, Scoped.prefixPaddingH)
          .glassEffect(
            colorSchemeAwareGlass.tint(.secondary).interactive(),
            in: .rect(cornerRadius: Scoped.prefixFrameCornerRadius))
      }

      // Battle Time String
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

        ForEach(IkaMockData.getBattleRotations()[modeSelection] ?? []) { rotation in
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
