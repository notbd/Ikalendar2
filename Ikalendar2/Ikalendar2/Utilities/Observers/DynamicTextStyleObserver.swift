//
//  DynamicTextStyleObserver.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import Combine
import UIKit

// MARK: - DynamicTextStyleObserver

class DynamicTextStyleObserver: NSObject {
  static let shared = DynamicTextStyleObserver()

  /// Combine publisher to notify subscribers of changes
  let textSizeDidChange = PassthroughSubject<Void, Never>()

  // MARK: Lifecycle

  override private init() {
    super.init()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(contentSizeCategoryDidChange),
      name: UIContentSizeCategory.didChangeNotification,
      object: nil)
  }

  // MARK: Private

  @MainActor
  @objc
  private func contentSizeCategoryDidChange(notification _: Notification) {
    UIFontCustomizer.customizeNavigationTitleText()
    textSizeDidChange.send()
  }
}
