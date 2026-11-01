// https://vitepress.dev/guide/custom-theme

import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme-without-fonts'
import { h } from 'vue'
import HomeCustomBody from '../HomeCustomBody.vue'
import CustomInstallRequirement from './CustomInstallRequirement.vue'
import CustomVPLink from './CustomVPLink.vue'
import './myCustomVars.css'
import 'virtual:uno.css'

export default {
  extends: DefaultTheme,
  Layout: () => {
    return h(DefaultTheme.Layout, null, {
      // https://vitepress.dev/guide/extending-default-theme#layout-slots
      'home-hero-actions-after': () => h(CustomInstallRequirement),
    })
  },
  enhanceApp({ app }) {
    app.component('HomeCustomBody', HomeCustomBody)
    app.component('CustomVPLink', CustomVPLink)
  },
} satisfies Theme
