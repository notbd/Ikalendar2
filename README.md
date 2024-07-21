<!-- markdownlint-disable MD033 MD041 -->

<p align="center">
  <img
    src="./Resources/MetaAssets/AppIcons/ikalendar2-app-icon-default-masked.png"
    alt="ikalendar2 logo"
    width=120/>
</p>

<h1 align="center"/>ikalendar2</h1>

<p align="center">
Track Splatoon 2 rotation schedules with style and ease.
</p>

![Hero](./Resources/MetaAssets/Demos/demo-universal-og.png)

# Introduction

**ikalendar2** is an iOS / iPadOS companion app for tracking Splatoon 2 rotation schedules. It helps you stay up-to-date with the latest information effortlessly - unlike the clumsy and sluggish experience on the official app from Nintendo.

A typical workflow on Nintendo's app to check rotation for a specific mode and timeslot would involve clicking through multiple unrelated screens and waiting for things to load (very slowly!) at each step. Coupled with its poor and cluttered navigation design that easily leads to misclicks and going back and forth, such a seemingly trivial task could take as long as **15-25 seconds** on average.

ikalendar2, in contrast, delivers the information that matters to you **immediately** upon launch. It fetches only the necessary data from sources, processes it and presents it through a clean and streamlined interface. Additionally, ikalendar2 offers a proud collection of quality-of-life features and customization options to make your experience enjoyable and personalized.

The app is entirely built in SwiftUI and utilizes some of the latest features and APIs available. It is designed to be fast, modern, user-friendly, with a touch of fun and vibrancy inspired by the game itself.

# Features

- Quick access to Splatoon 2 rotation schedules through a clean, modern interface optimized for both iOS and iPadOS devices.
- Robust **auto-refresh** system ensures the latest rotation information is always available.
- Smooth, game-inspired **animations** and thoughtful details throughout the app for a fun and pleasant experience.
- Extensive **customization options** including alternative stage appearances, app icons, and more.
- Native localization support for **English** and **Japanese**.

# Installation

ikalendar2 is available for download on the App Store for free.

[![Download on the App Store](./Resources/MetaAssets/Badges/download-app-store-EN-black.svg)](https://apps.apple.com/app/ikalendar2/id1529193361)

# Compatibilities / Environments

- iOS / iPadOS `17.0` or later is required for the latest version of ikalendar2.

- Compatibility with macOS running on Apple Silicon is not targeted, but beta tests on MacBook Air M1 with macOS `14.5` show no breaking issues.

- visionOS compatibility is not tested for.

- watchOS, tvOS, and macOS running on Intel-based Macs are not yet supported.

- Development environment includes Xcode `15.4` and Swift `5.10`.

# Previews

<!-- Have to set both `align="center"` and `style="text-align: center;"`
since some markdown parsers don't support one or the other.  -->
<table align="center" width="100%" style="text-align: center;">
  <thead>
    <tr>
      <th align="center" width="33%" style="text-align: center;">Ranked Battle (English)</th>
      <th align="center" width="33%" style="text-align: center;">League Battle (English)</th>
      <th align="center" width="33%" style="text-align: center;">Salmon Run (Japanese)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="33%" style="text-align: center;">No Customization</td>
      <td align="center" width="33%" style="text-align: center;">Custom Stage Image & Bottom Toolbar</td>
      <td align="center" width="33%" style="text-align: center;">Custom Stage Image & Bottom Toolbar</td>
    </tr>
    <tr>
      <td align="center" width="33%"><img alt="Battle" src="./Resources/MetaAssets/Demos/demo-phone-battle.png" width="100%"></td>
      <td align="center" width="33%"><img alt="Battle Alt" src="./Resources/MetaAssets/Demos/demo-phone-battle-alt.png" width="100%"></td>
      <td align="center" width="33%"><img alt="Salmon Run" src="./Resources/MetaAssets/Demos/demo-phone-salmon.png" width="100%"></td>
    </tr>
  </tbody>
</table>

<table align="center" width="100%" style="text-align: center;">
  <thead>
    <tr>
      <th align="center" width="33%" style="text-align: center;">Welcome Screen (icon is clickable!)</th>
      <th align="center" width="33%" style="text-align: center;">Transition between Rotations</th>
      <th align="center" width="33%" style="text-align: center;">Auto Refresh for Newly Available Rotations</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="33%" style="text-align: center;"><img alt="Welcome Screen" src="./Resources/MetaAssets/Demos/gif-welcome.gif" width="100%"></td>
      <td align="center" width="33%" style="text-align: center;"><img alt="Rotation Transition" src="./Resources/MetaAssets/Demos/gif-transition.gif" width="100%"></td>
      <td align="center" width="33%" style="text-align: center;"><img alt="Auto Refresh" src="./Resources/MetaAssets/Demos/gif-auto-refresh.gif" width="100%"></td>
    </tr>
  </tbody>
</table>

# Acknowledgements

ikalendar2 is made possible thanks to the following projects:

<!-- markdownlint-disable-next-line MD001 -->
### Data Sources

- [Splatoon2.ink](https://github.com/misenhower/splatoon2.ink/wiki/Data-access-policy#data-urls)
- [JelonzoBot](https://splatoon.oatmealdome.me/about)

### Dependencies

- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [SimpleHaptics](https://github.com/notbd/SimpleHaptics)
- [AlertKit](https://github.com/sparrowcode/AlertKit)

# Website

[ikalendar.app](https://ikalendar.app) is the official website for ikalendar2. Source code of the website is located [here](https://github.com/notbd/Ikalendar2/tree/main/docs) within the `/docs` directory under the current repo.

# Archive

Early versions of ikalendar2 was archived in a [separate repository](https://github.com/notbd/ikalendar-2-archived). The reason for a new repo at the time was due to the need for a major refactoring, as well as implementing more robust coding practices and standards.

# Privacy

ikalendar2 does not collect any data about the user or upload any information. Here's the link to the [Privacy Policy](https://ikalendar.app/privacy-policy).

# License

ikalendar2 is licensed under the [GPL-3.0 License](./LICENSE).

# Disclaimer

ikalendar2 is a third-party companion app for Splatoon™ 2 and is not affiliated with Nintendo. All associated item names, logos, and trademarks are the property of their respective owners.
