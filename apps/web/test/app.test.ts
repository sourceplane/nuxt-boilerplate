import { expect, it, vi } from 'vitest';
import { mountSuspended } from '@nuxt/test-utils/runtime';
import { useAppConfig } from '#imports';
import App from '../app.vue';

// app.vue is the whole app: <NuxtWelcome /> (the title it sets lives in
// <head>; the body carries the welcome copy).
it('renders the welcome page', async () => {
  const app = await mountSuspended(App);
  const text = app.text();
  expect(text).toContain('Get started');
  expect(text).toContain('Remove this welcome page by replacing <NuxtWelcome/> in app.vue with your own code.');
});

// The site's name is written once, in app.config.ts, and the page title is
// read from it — not the welcome page's own "Welcome to Nuxt!".
it('titles the page with the site name from app.config.ts', async () => {
  const { siteName } = useAppConfig();
  expect(siteName.trim()).not.toBe('');
  await mountSuspended(App);
  await vi.waitFor(() => expect(document.title).toBe(siteName));
});
