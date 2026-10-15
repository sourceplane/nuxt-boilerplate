// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  routeRules: {
    // prerender index route by default
    '/': { prerender: true },
  },
  // Vercel's zero-config Nuxt hosting becomes Nitro's Cloudflare Workers
  // preset: the build emits .output/server/index.mjs (the Worker) and
  // .output/public (the static assets, the prerendered index among them).
  // The committed wrangler.jsonc is the deployable config; Nitro's own
  // generated one (deployConfig) is off so it does not write a second
  // wrangler.json and warn that main/assets are overridden.
  nitro: {
    preset: 'cloudflare_module',
    cloudflare: {
      deployConfig: false,
    },
  },
});
