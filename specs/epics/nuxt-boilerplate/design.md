# nuxt-boilerplate — design

## 1. What the template is

Nuxt 3.8 with the default layout: `app.vue` renders `<NuxtWelcome />` (the
welcome page Nuxt ships), `nuxt.config.ts` turns on devtools and sets
`routeRules['/'] = { prerender: true }`, `public/favicon.ico`, and
`postinstall: nuxt prepare`. There is no `pages/` directory, so there is no
router: every path renders `app.vue`. On Vercel the platform picks Nitro's
`vercel` preset at build time; nothing in the template names a host.

## 2. The mapping (Vercel → Cloudflare)

| Vercel primitive the template uses | Here |
|---|---|
| Zero-config hosting: Nitro's `vercel` preset, chosen by the platform (a serverless function, Vercel's CDN for the prerendered index) | Nitro's `cloudflare_module` preset, named in `nuxt.config.ts`: the Worker under `.output/server/index.mjs` (ESM, `fetch` handler, `chunks/`), the static output under `.output/public/` (`index.html`, `_payload.json`, `_nuxt/*` hashed assets, `favicon.ico`, a `_headers` file with immutable caching for `/_nuxt/*`) |
| The prerendered `/` served by the CDN | `.output/public/index.html`, served by Static Assets before the Worker runs; the Worker renders everything else per request |
| Node.js runtime for the server | `nodejs_compat` in `wrangler.jsonc`; Nitro's preset reads the flag and bundles its Workers Node-compat shims (`unenv`) |
| Build settings in the dashboard | `wrangler.jsonc` (committed): worker name, compatibility date and flags, `main`, the `ASSETS` binding over `.output/public` |
| Deploy on push | Orun: `apps/web/component.yaml` (`cloudflare-workers-assets-turbo`) deploys `nuxt-boilerplate-web-{stage,prod}` on merge to `main` once the product is linked |

Alternative rejected: `nuxt generate` + assets only (a static export). It
would drop Nitro's server — the per-request rendering of every
non-prerendered path, server routes, route rules — which is what a Nuxt
boilerplate is the starting point for; the welcome page alone does not need
a server, but an app grown from it will.

Alternative rejected: Cloudflare Pages (`cloudflare_pages` preset). Pages is
the older target; Workers + Static Assets is where Cloudflare's framework
guides point, and it is what the Cirrus component deploys.

## 3. The repository

```
apps/web               the boilerplate (app.vue, public/, server/) + the Nitro preset
  nuxt.config.ts       cloudflare_module preset, deployConfig off, the route rules as upstream
  wrangler.jsonc       worker name, compatibility date and flags, main, the ASSETS binding
  component.yaml       build with turbo, deploy wrangler.jsonc, smoke /
  vitest.config.ts     @nuxt/test-utils' Vitest config (environment: nuxt) for the app test
  test/app.test.ts     mounts app.vue with mountSuspended and reads the welcome copy
```

No `tests/` package: `app.vue` mounts only under Nuxt's Vite config and
auto-imports (`<NuxtWelcome />` is one), so vitest runs in `apps/web` with
`defineVitestConfig` from `@nuxt/test-utils/config`.

## 4. The build

`pnpm --filter @app/web build` = `nuxt build` → Vite builds the client
(`.output/public/_nuxt/*`) and the server, Nitro prerenders `/` and
`/_payload.json` into `.output/public/`, then bundles the Worker to
`.output/server/index.mjs` (+ `chunks/`). Nitro's own generated
`wrangler.json` (`cloudflare.deployConfig`, on by default for the Workers
preset) is turned off: it would write a second config beside the Worker and
warn that the committed `main`/`assets` are ignored. The Orun component
deploys the committed `wrangler.jsonc` with `--name
nuxt-boilerplate-web-<env>`. Locally, `pnpm --filter @app/web preview` runs
`wrangler dev` over the same config.

## 5. Out of scope

Pages, layouts and server routes (the template has none), Nuxt 4's `app/`
directory layout (the template's files stay at the root, which Nuxt 4
accepts), a custom domain, and Cloudflare bindings (nothing in the template
reads one).
