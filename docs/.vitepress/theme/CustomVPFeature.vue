<script setup lang="ts">
import type { DefaultTheme } from 'vitepress/theme-without-fonts'
import { VPImage } from 'vitepress/theme-without-fonts'

defineProps<{
  icon?: DefaultTheme.FeatureIcon
  title: string
  details?: string
}>()
</script>

<template>
  <div class="VPFeature">
    <article class="box">
      <div v-if="typeof icon === 'object' && icon.wrap" class="icon">
        <VPImage
          :image="icon"
          :alt="icon.alt"
          :height="icon.height || 48"
          :width="icon.width || 48"
        />
      </div>
      <VPImage
        v-else-if="typeof icon === 'object'"
        :image="icon"
        :alt="icon.alt"
        :height="icon.height || 48"
        :width="icon.width || 48"
      />
      <div v-else-if="icon" class="icon" v-html="icon" />
      <h2 class="title" v-html="title" />
      <p v-if="details" class="details" v-html="details" />
    </article>
  </div>
</template>

<style scoped>
.VPFeature {
  display: block;
  border: 1px solid var(--vp-c-bg-soft);
  border-radius: 12px;
  height: 100%;
  background-color: var(--vp-c-bg-soft);
  transition:
    border-color 0.3s ease-out,
    background-color 0.3s ease-out;
}

.VPFeature:hover {
  border-color: var(--vp-c-brand-1);
}

.VPFeature .icon {
  transition: color 0.3s ease-out;
}

.VPFeature:hover .icon {
  color: var(--vp-c-brand-1);
}

.VPFeature .title {
  background: var(--vp-home-hero-name-background);
  -webkit-background-clip: text;
  background-clip: text;
  transition: color 0.3s ease-out;
}

.VPFeature:hover .title {
  color: transparent;
}

.box {
  display: flex;
  flex-direction: column;
  padding: 24px;
  height: 100%;
}

.box > :deep(.VPImage) {
  margin-bottom: 20px;
}

.icon {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-bottom: 20px;
  border-radius: 6px;
  background-color: var(--vp-c-default-soft);
  width: 48px;
  height: 48px;
  font-size: 24px;
}

.title {
  line-height: 24px;
  font-size: 16px;
  font-weight: 600;
}

.details {
  flex-grow: 1;
  padding-top: 8px;
  line-height: 24px;
  font-size: 14px;
  font-weight: 500;
  color: var(--vp-c-text-2);
}
</style>
