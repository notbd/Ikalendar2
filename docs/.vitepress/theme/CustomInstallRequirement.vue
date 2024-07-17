<script setup>
import { useData } from 'vitepress'

const { frontmatter } = useData()
const compatibility = frontmatter.value.hero.compatibility
</script>

<template>
  <p v-if="compatibility" class="compatibility-message">
    {{ compatibility }}
  </p>
</template>

<style scoped>
.compatibility-message {
  font-size: 0.85em;
  color: var(--vp-c-text-2);
  font-weight: 500;
  margin-top: 0.5em;
  margin-left: 0.1em;
}
</style>
