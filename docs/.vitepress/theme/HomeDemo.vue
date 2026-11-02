<script setup lang="ts">
import { useData } from 'vitepress'

const { frontmatter } = useData()
</script>

<template>
  <div
    flex flex-col items-center
    mt-16 md:mt-24 gap-y-12
  >
    <img
      v-if="frontmatter.demo.image"
      :src="frontmatter.demo.image.src"
      :alt="frontmatter.demo.image.alt"
      width="3840"
      height="2160"
      loading="lazy"
      decoding="async"
      hidden md:block
    >
    <img
      v-if="frontmatter.demo.imageCompact"
      :src="frontmatter.demo.imageCompact.phoneSrc"
      :alt="frontmatter.demo.imageCompact.phoneAlt"
      width="1500"
      height="1500"
      loading="lazy"
      decoding="async"
      md:hidden
    >
    <img
      v-if="frontmatter.demo.imageCompact"
      :src="frontmatter.demo.imageCompact.tabletSrc"
      :alt="frontmatter.demo.imageCompact.tabletAlt"
      width="1500"
      height="1135"
      loading="lazy"
      decoding="async"
      md:hidden
    >
  </div>
</template>
