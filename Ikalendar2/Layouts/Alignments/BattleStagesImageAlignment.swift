//
//  BattleStagesImageAlignment.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension VerticalAlignment {
  private enum BattleStagesImageAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      context[.top]
    }
  }

  static let battleStagesImageAlignment: VerticalAlignment = .init(BattleStagesImageAlignment.self)
}
