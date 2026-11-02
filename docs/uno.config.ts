import axios from 'axios'
import { defineConfig, presetAttributify, presetIcons, presetUno, presetWebFonts, transformerDirectives } from 'unocss'

export default defineConfig({
  presets: [
    presetUno(),
    presetIcons(),
    presetAttributify(),
    presetWebFonts({
      // use axios with an https proxy
      customFetch: (url: string) => axios.get(url).then(it => it.data),
      provider: 'fontshare',
      fonts: {
        sans: ['General Sans'],
      },
    }),
  ],
  transformers: [
    transformerDirectives(),
  ],
})
