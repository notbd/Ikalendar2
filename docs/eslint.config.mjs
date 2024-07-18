import antfu from '@antfu/eslint-config'

export default antfu(
  {
    stylistic: {
      indent: 2,
      quotes: 'single',
    },

    formatters: {
      css: true,
      html: true,
      markdown: 'prettier',
    },

    typescript: true,
    vue: true,
  },

  {
    rules: {
    // use `type` for type definitions instead of `interface`
      '@typescript-eslint/consistent-type-definitions': ['error', 'type'],
      'n/prefer-global/process': ['error', 'always'],
    },
  },
)
