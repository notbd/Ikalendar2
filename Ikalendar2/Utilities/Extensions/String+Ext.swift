//
//  String+Ext.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension String {
  var localizedStringKey: LocalizedStringKey { LocalizedStringKey(self) }
}

extension String {
  /// Translate a string using the provided localizations in the bundle.
  /// - Parameters:
  ///   - key: The string to be translated from.
  ///   - locale: The locale of the translation(default to .current).
  /// - Returns: The translated String.
  static func localizedString(
    for key: String,
    locale: Locale = .current)
    -> String
  {
    let language = locale.language.languageCode?.identifier
    let path = Bundle.main.path(forResource: language, ofType: "lproj")!
    let bundle = Bundle(path: path)!
    let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")

    return localizedString
  }
}
