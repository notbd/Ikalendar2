//
//  Binding+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension Binding {
  /// Run a handler function when the binding value is set.
  ///
  /// Use instead of SwiftUI built-in onChange() because as of iOS14,
  /// the value comparison will fail about half of the times.
  /// Hope this bug will be fixed in the future OS updates
  ///
  /// - Parameter handler: The handler function to be called on the new value.
  /// - Returns: The original binding.
  public func onSet(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        self.wrappedValue = newValue
        handler(newValue)
      })
  }
}
