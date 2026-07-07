//
//  UserDefaults+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import Foundation

extension UserDefaults {
  /// Reads a String-raw-representable value, preserving the on-disk encoding `@AppStorage` used.
  func ikaLoadEnum<T: RawRepresentable>(forKey key: String, default defaultValue: T) -> T
    where T.RawValue == String
  {
    string(forKey: key).flatMap(T.init(rawValue:)) ?? defaultValue
  }

  /// Reads a Bool with an explicit fallback.
  /// - Important: `bool(forKey:)` returns `false` for missing keys, which would silently break
  ///   preferences whose default is `true` (e.g. onboarding). Always check key presence first.
  func ikaLoadBool(forKey key: String, default defaultValue: Bool) -> Bool {
    object(forKey: key) as? Bool ?? defaultValue
  }
}
