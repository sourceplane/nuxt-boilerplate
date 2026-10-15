<script setup lang="ts">
// The site's name, from app.config.ts, is the page title.
const { siteName } = useAppConfig();
</script>

<template>
  <div>
    <NuxtWelcome :title="siteName" />
  </div>
</template>
