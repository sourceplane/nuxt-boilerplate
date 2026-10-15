import { defineVitestConfig } from '@nuxt/test-utils/config';

// Nuxt's own Vite config plus the `nuxt` vitest environment, so app.vue (and
// the auto-imported <NuxtWelcome />) mounts under happy-dom through
// @nuxt/test-utils' mountSuspended.
export default defineVitestConfig({
  test: {
    environment: 'nuxt',
    include: ['test/**/*.test.ts'],
  },
});
