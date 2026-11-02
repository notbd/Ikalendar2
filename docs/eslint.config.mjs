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
      // antfu v10 autofixes this to write trustPolicy: no-downgrade into pnpm-workspace.yaml,
      // which then fails install with ERR_PNPM_TRUST_DOWNGRADE (vite@5.4.21 from vitepress 1.6.4)
      'pnpm/yaml-enforce-settings': 'off',
    },
  },
)
