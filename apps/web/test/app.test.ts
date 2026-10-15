import { expect, it } from 'vitest';
import { mountSuspended } from '@nuxt/test-utils/runtime';
import App from '../app.vue';

// app.vue is the whole app: <NuxtWelcome /> (the title it sets, "Welcome to
// Nuxt!", lives in <head>; the body carries the welcome copy).
it('renders the welcome page', async () => {
  const app = await mountSuspended(App);
  const text = app.text();
  expect(text).toContain('Get started');
  expect(text).toContain('Remove this welcome page by replacing <NuxtWelcome/> in app.vue with your own code.');
});
