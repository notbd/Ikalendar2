//
//  QuickBorder.swift
//  Ikalendar2
//
//  Copyright (c) TIANWEI ZHANG. All rights reserved.
//

import SwiftUI

/// A modifier that quickly applies a colored border to the view.
/// <FOR DEBUGGING PURPOSES>
extension View {
  func quickBorderRed(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.red
        .opacity(opacity),
      width: lineWidth)
  }

  func quickBorderBlue(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.blue
        .opacity(opacity),
      width: lineWidth)
  }

  func quickBorderOrange(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.orange
        .opacity(opacity),
      width: lineWidth)
  }

  func quickBorderGreen(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.green
        .opacity(opacity),
      width: lineWidth)
  }

  func quickBorderPurple(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.purple
        .opacity(opacity),
      width: lineWidth)
  }

  func quickBorderYellow(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.yellow
        .opacity(opacity),
      width: lineWidth)
  }

  func quickBorderBlack(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.black
        .opacity(opacity),
      width: lineWidth)
  }

  func quickBorderWhite(
    opacity: Double = 1,
    lineWidth: CGFloat = 1)
    -> some View
  {
    border(
      Color.white
        .opacity(opacity),
      width: lineWidth)
  }
}
