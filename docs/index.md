---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  image:
    src: /assets/icon-squircle-1024.png
    alt: ikalendar2's icon
  name: ikalendar2
  text: Track Splatoon 2 Rotations with Style and Ease
  tagline: Fast · Intuitive · Customizable
  appStoreLink: https://apps.apple.com/app/id1529193361
  appStoreImageDark: /assets/download-app-store-EN-black.svg
  appStoreImageLight: /assets/download-app-store-EN-white.svg
  compatibility: Requires iOS and iPadOS 17.0 or later.
  actions:
    # first action button will be replaced by the App Store badge
    - theme: brand
      text: Download on the App Store
      link: https://apps.apple.com/app/id1529193361
    - theme: brand
      text: View on GitHub
      link: https://github.com/notbd/Ikalendar2

features:
  - title: Fully SwiftUI
    details: Focusing on speed and readability, ikalendar2 is built entirely with SwiftUI, leveraging the latest APIs to deliver a fast and modern app experience.
  - title: Auto Refresh
    details: The robust auto-refresh system ensures the lastest rotation info is always ready. Never have to worry about doing it yourself!
  - title: Animations
    details: Enjoy meticulously designed, game-inspired animations and transitions throughout the app. Rotation tracking is just as fun and vibrant as the game itself!
  - title: Extensive Customizations
    details: Fancy a different look for the stages? In mood for a new app icon? Make it truly yours with a variety of personalization options.
  - title: Multi-Language Support
    details: In-App localization support is now available for both English and Japanese.
  - title: Open Source
    details: ikalendar2 is 100% open source :]

dependencies:
  message: ikalendar2 is free and open source, made possible by the following projects.
  content:
    - tier: Data Sources
      size: big
      items:
        - name: misenhower/splatoon2.ink
          url: https://github.com/misenhower/splatoon2.ink/wiki/Data-access-policy#data-urls
          icon: github
        - name: JelenzoBot
          url: https://splatoon.oatmealdome.me/about
    - tier: Open Source Libraries
      size: big
      items:
        - name: SwiftyJSON/SwiftyJSON
          url: https://github.com/SwiftyJSON/SwiftyJSON
          icon: github
          description: The better way to deal with JSON data in Swift.
        - name: notbd/SimpleHaptics
          url: https://github.com/notbd/SimpleHaptics
          icon: github
          description: Simple and easy haptics generation.
        - name: sparrowcode/AlertKit
          url: https://github.com/sparrowcode/AlertKit
          icon: github
          description: Alerts that resemble native style from Apple Music.
---

<HomeCustomBody />
