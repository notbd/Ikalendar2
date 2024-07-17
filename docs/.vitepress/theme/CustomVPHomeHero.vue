<script setup lang="ts">
import { useData } from 'vitepress'
import CustomVPHero from './CustomVPHero.vue'

const { frontmatter: fm } = useData()
</script>

<template>
  <CustomVPHero
    v-if="fm.hero"
    class="VPHomeHero"
    :name="fm.hero.name"
    :text="fm.hero.text"
    :tagline="fm.hero.tagline"
    :image="fm.hero.image"
    :app-store-link="fm.hero.appStoreLink"
    :app-store-image-dark="fm.hero.appStoreImageDark"
    :app-store-image-light="fm.hero.appStoreImageLight"
    :compatibility="fm.hero.compatibility"
    :actions="fm.hero.actions"
  >
    <template #home-hero-info-before>
      <slot name="home-hero-info-before" />
    </template>
    <template #home-hero-info>
      <slot name="home-hero-info" />
    </template>
    <template #home-hero-info-after>
      <slot name="home-hero-info-after" />
    </template>
    <template #home-hero-actions-after>
      <slot name="home-hero-actions-after" />
    </template>
    <template #home-hero-image>
      <slot name="home-hero-image" />
    </template>
  </CustomVPHero>
</template>
