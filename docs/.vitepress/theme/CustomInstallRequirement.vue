<script setup>
import { useData } from 'vitepress'

const { frontmatter } = useData()
const compatibility = frontmatter.value.hero.compatibility
</script>

<template>
  <p
    v-if="compatibility"
    class="compatibility-message"
    text="0.85rem"
    m="t-2 l-[0.1em]"
    font-medium
  >
    {{ compatibility }}
  </p>
</template>

<style scoped>
.compatibility-message {
  color: var(--vp-c-text-2);
}
</style>
