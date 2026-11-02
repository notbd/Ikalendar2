//
//  View+Ext.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

extension View {
  /// Applies `transformation` to the view, so a helper function can stay inside a linear
  /// modifier chain.
  ///
  /// ### Usage example: ###
  /// ```
  /// var body: some View {
  ///   myView
  ///     .apply { $0.padding(8) }
  /// }
  /// ```
  public func apply(
    _ transformation: (Self) -> some View)
    -> some View
  {
    transformation(self)
  }

  /// Applies `transformation` only while `condition` is true. Changing `condition` changes the
  /// view's identity, so `@State` inside resets.
  ///
  /// ### Usage example: ###
  /// ```
  /// var body: some View {
  ///   myView
  ///     .if(X) { $0.padding(8) }
  ///     .if(Y) { $0.background(Color.blue) }
  /// }
  /// ```
  @ViewBuilder
  public func `if`(
    _ condition: Bool,
    transformation: (Self) -> some View)
    -> some View
  {
    if condition { transformation(self) }
    else { self }
  }

  /// Applies one of two transformations by `condition`. Same identity caveat as
  /// `if(_:transformation:)`.
  ///
  /// ### Usage example: ###
  /// ```
  /// var body: some View {
  ///   myView
  ///     .if(X) { $0.padding(8) } else: { $0.background(Color.blue) }
  /// }
  /// ```
  @ViewBuilder
  public func `if`(
    _ condition: Bool,
    if trueTransformation: (Self) -> some View,
    else falseTransformation: (Self) -> some View)
    -> some View
  {
    if condition { trueTransformation(self) }
    else { falseTransformation(self) }
  }

  /// Applies `transformation` with the unwrapped value when `value` is non-nil.
  ///
  /// ### Usage example: ###
  /// ```
  /// var body: some View {
  ///   myView
  ///     .ifLet(optionalColor) { $0.foregroundStyle($1) }
  /// }
  /// ```
  @ViewBuilder
  public func ifLet<V>(
    _ value: V?,
    transformation: (Self, V) -> some View)
    -> some View
  {
    if let value { transformation(self, value) }
    else { self }
  }
}

extension View {
  /// Adjusts the horizontal alignment of the view.
  ///
  /// This function extends the `View` by providing a more readable way to set horizontal alignment.
  /// The view is aligned within an infinite width to achieve the desired horizontal alignment.
  ///
  /// - Parameters:
  ///   - alignment: The horizontal alignment type. Defaults to `.center`.
  ///
  /// - Returns: A view that adjusts its alignment according to the specified parameter.
  public func hAlignment(_ alignment: Alignment = .center) -> some View {
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
  ///
  /// - Returns: A view that adjusts its alignment according to the specified parameter.
  public func vAlignment(_ alignment: Alignment = .center) -> some View {
    frame(
      maxHeight: .infinity,
      alignment: alignment)
  }
}
