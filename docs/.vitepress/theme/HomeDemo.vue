<script setup lang="ts">
import { useData } from 'vitepress'

const { frontmatter } = useData()
</script>

<template>
  <div
    flex flex-col items-center
    mt-12 md:mt-24 gap-y-4
  >
    <img
      v-if="frontmatter.demo.image"
      :src="frontmatter.demo.image.src"
      :alt="frontmatter.demo.image.alt"
      hidden sm:block
    >
    <img
      v-if="frontmatter.demo.imageCompact"
      :src="frontmatter.demo.imageCompact.tabletSrc"
      :alt="frontmatter.demo.imageCompact.tabletAlt"
      sm:hidden
    >
    <img
      v-if="frontmatter.demo.imageCompact"
      :src="frontmatter.demo.imageCompact.phoneSrc"
      :alt="frontmatter.demo.imageCompact.phoneAlt"
      px-16
      sm:hidden
    >
  </div>
</template>
