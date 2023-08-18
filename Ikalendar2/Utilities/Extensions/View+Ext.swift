//
//  View+Ext.swift
//  Ikalendar2
//
//  Copyright (c) 2023 TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension View {
  /// This function will apply transform to our view when condition is true,
  /// otherwise it will leave the original view untouched.
  ///
  /// ### Usage example: ###
  /// ```
  /// var body: some view {
  ///   myView
  ///     .if(X) { $0.padding(8) }
  ///     .if(Y) { $0.background(Color.blue) }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - condition: The condition for the transform.
  ///   - transform: The transform function/modifier.
  /// - Returns: The resulted view.
  @ViewBuilder
  func `if`(
    _ condition: Bool,
    transform: (Self) -> some View)
    -> some View
  {
    if condition {
      transform(self)
    }
    else {
      self
    }
  }

  /// This function will apply a transform to our view when condition is true,
  /// and the another transform to the view otherwise.
  ///
  /// ### Usage example: ###
  /// ```
  /// var body: some view {
  ///   myView
  ///     .if(X) { $0.padding(8) } else: { $0.background(Color.blue) }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - condition: The condition for the transform.
  ///   - ifTransform: The transform to apply if the condition is true.
  ///   - elseTransform: The condition to apply for the transform is false.
  /// - Returns: The resulted view.
  @ViewBuilder
  func `if`(
    _ condition: Bool,
    if ifTransform: (Self) -> some View,
    else elseTransform: (Self) -> some View)
    -> some View
  {
    if condition {
      ifTransform(self)
    }
    else {
      elseTransform(self)
    }
  }

  /// This function will apply a transform to our view
  /// if the value is non-nil.
  ///
  /// ### Usage example: ###
  /// ```
  /// var body: some view {
  ///   myView
  ///     .ifLet(optionalColor) { $0.foregroundColor($1) }
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - value: The optional value to evaluate.
  ///   - transform: The transform function/modifier.
  /// - Returns: The resulted view.
  @ViewBuilder
  func ifLet<V>(
    _ value: V?,
    transform: (Self, V) -> some View)
    -> some View
  {
    if let value {
      transform(self, value)
    }
    else {
      self
    }
  }

  /// Adjusts the horizontal alignment of the view.
  ///
  /// This function extends the `View` by providing a more readable way to set horizontal alignment.
  /// The view is aligned within an infinite width to achieve the desired horizontal alignment.
  ///
  /// - Parameters:
  ///   - alignment: The horizontal alignment type. Defaults to `.center`.
  /// - Returns: A view that adjusts its alignment according to the specified parameter.
  @ViewBuilder
  func hAlignment(_ alignment: Alignment = .center) -> some View {
    frame(
      maxWidth: .infinity,
      alignment: alignment)
  }

  /// Adjusts the vertical alignment of the view.
  ///
  /// This function extends the `View` by providing a more readable way to set vertical alignment.
  /// The view is aligned within an infinite height to achieve the desired vertical alignment.
  ///
  /// - Parameters:
  ///   - alignment: The vertical alignment type. Defaults to `.center`.
  /// - Returns: A view that adjusts its alignment according to the specified parameter.
  @ViewBuilder
  func vAlignment(_ alignment: Alignment = .center) -> some View {
    frame(
      maxHeight: .infinity,
      alignment: alignment)
  }
}
