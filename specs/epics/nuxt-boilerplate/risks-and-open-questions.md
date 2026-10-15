# nuxt-boilerplate — risks and open questions

## NB-A — Nuxt 3.8 → 4 (RESOLVED)

The template floats `nuxt ^3.8.2` (November 2023). The port runs the
current major, Nuxt 4.6. Nothing the template uses changed: `app.vue`,
`<NuxtWelcome />`, `routeRules`, `devtools`, `nuxt prepare`. Nuxt 4's new
`app/` source directory is opt-in by its presence — with no `app/`
directory Nuxt keeps the root as `srcDir`, so `app.vue` stays where
upstream put it and no `future.compatibilityVersion` or `srcDir` setting
is needed. The build and the preview verify it. Pinning Nuxt 3 (whose
Nitro 2.x has the same preset) is the fallback.

## NB-B — Nitro's generated wrangler config (RESOLVED)

Nitropack 2.13 turns `cloudflare.deployConfig` on for the Workers preset:
it reads the nearest `wrangler.jsonc`, warns that `main` and `assets` are
"overridden and will be ignored", and writes `.output/server/wrangler.json`
(adding `no_nodejs_compat_v2` to the flags). The repository convention is
one committed config the component deploys, so `deployConfig: false` and
the committed `wrangler.jsonc` carries `main` and `assets` itself.
`nodeCompat` is still inferred from the committed `nodejs_compat` flag, so
the Worker bundle gets Nitro's Node-compat shims.

## NB-C — `nodejs_compat` without `no_nodejs_compat_v2` (ACCEPTED, watched)

Nitro's generated config adds `no_nodejs_compat_v2` beside
`nodejs_compat`, with a warning that the v2 behaviour "can cause issues
with nitro". Cloudflare's own Nuxt guide (and `wrangler setup`) deploys
with `nodejs_compat` alone, which is what the committed config carries;
the welcome page renders under `wrangler dev` with compatibility date
2026-10-01. If a later Nuxt feature trips on the runtime's built-in Node
modules, adding `no_nodejs_compat_v2` to `compatibility_flags` is the fix.

## NB-D — Every path renders `app.vue` (ACCEPTED, documented)

The template has no `pages/`, so there is no router and no 404: `/nope`
renders the welcome page with a 200, on Vercel as here. The port keeps
the template as written; a `pages/` directory would bring the router and
Nuxt's 404 page.

## NB-E — Tests inside the app (SETTLED)

`<NuxtWelcome />` is an auto-imported component and `app.vue` mounts only
under Nuxt's Vite config, so vitest runs in `apps/web` with
`defineVitestConfig` (`environment: 'nuxt'`, happy-dom). The repository
convention of a separate `tests/<app>` package is kept for the Next.js
ports; here it would only add a second Nuxt toolchain. "Welcome to Nuxt!"
is the page title `<NuxtWelcome />` sets through `useHead`, not body text,
so the test reads the welcome copy in the body and the smoke test greps
the title.

## NB-F — Node 25 locally (NOTED)

Nuxt 4.6 declares `node ^22.21 || ^24.11 || >=26` and prints an
"unsupported" banner on Node 25; everything runs. `Checks` and the Orun
component use Node 22.
