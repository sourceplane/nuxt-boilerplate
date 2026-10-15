# apps/web — the site

A Nuxt site from Vercel's
[Nuxt boilerplate](https://github.com/vercel/examples/tree/main/framework-boilerplates/nuxtjs)
(MIT): `app.vue` rendering the Nuxt welcome page, with the index route
pre-rendered, running on Cloudflare Workers + Static Assets through Nitro's
`cloudflare_module` preset.

The site's name is `siteName` in `app.config.ts`; the page title reads it.
Replace `<NuxtWelcome />` in `app.vue` with your own code, and add a
`pages/` directory when you want routes.

```bash
pnpm dev        # nuxt dev on http://localhost:3000
pnpm test       # vitest in the nuxt environment (@nuxt/test-utils)
pnpm build      # nuxt build → .output/server (the Worker) + .output/public (the assets)
pnpm preview    # wrangler dev over the built Worker (wrangler.jsonc)
```

How it is deployed — per environment, on merge to `main` — is the
repository's README and `component.yaml` beside this file.
