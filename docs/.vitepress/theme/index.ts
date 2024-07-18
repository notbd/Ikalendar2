// https://vitepress.dev/guide/custom-theme
import { h } from 'vue'
import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import './myCustomVars.css'
import 'virtual:uno.css'
import HomeCustomBody from '../HomeCustomBody.vue'
import CustomInstallRequirement from './CustomInstallRequirement.vue'

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
  },
} satisfies Theme
