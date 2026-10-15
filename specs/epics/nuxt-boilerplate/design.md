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
accepts), a custom-domain component (§6: the brokered deploy token carries no
zone permissions, so attaching a domain is the owner's step), and Cloudflare
bindings (nothing in the template reads one).

## 6. The baseline (NB3)

The repository instantiates new sites the way
[cirrus-baseline](https://github.com/sourceplane/cirrus-baseline) instantiates
products and the way
[portfolio-starter-kit](https://github.com/sourceplane/portfolio-starter-kit)
(`baseline-v2`) instantiates a Next.js site: a console card
(`blueprint.yaml`) the platform renders, a build document
(`repo-blueprint.yaml`) `orun new` runs, and a rename engine that makes the
copy somebody else's.

| portfolio-starter-kit | Here | Why the difference |
|---|---|---|
| `apps/web` + `tests/web`, two components in `02-site` | `apps/web` alone | a Nuxt component test needs Nuxt's Vite config and auto-imports, so the tests live in the app (NB-E); there is no test component to place, retouch or cover |
| the name seam `apps/web/app/site.ts` (`SITE_NAME`, `SOURCE_URL`) | `siteName` in `apps/web/app.config.ts`, read with `useAppConfig()` | an `app/` directory would make Nuxt 4 move its source root there and stop finding the root `app.vue` (risks NB-I); the site shows no source link, so the seam carries none |
| build origin baked in (`NEXT_PUBLIC_SITE_URL`, `SITE_URL`) | none | the welcome page carries no absolute link to its own origin; a custom domain is attached, not built in |
| smoke: the nav's `/blog` link and `/rss` | the `id="__nuxt"` root on `/`, and a 200 or 404 from the Worker on a path no asset matches | the old smoke grepped the title, which is now the owner's name; `/` alone is served by Static Assets without the Worker running (risks NB-L) |
| deployment record probes `/` and `/rss` | `/` and `/favicon.ico` (and an environment's custom `url`) | the routes this site has: the pre-rendered page and a static asset |
| stack-tectonic 0.19.0, because Turbopack refuses a lane-shared install | 0.19.0 too | Nuxt builds in either layout (risks NB-J), but one job per lane gains nothing from sharing, and the siblings stay on one pin |

**Identity in the app** is one literal: `siteName` in `apps/web/app.config.ts`.
`app.vue` passes it to `<NuxtWelcome :title>`, which sets `<title>` (the
component's own default is "Welcome to Nuxt!"); the baseline's own value is
"Nuxt Boilerplate". The rename writes it with `JSON.stringify`, so any name
the card's pattern admits — apostrophes and ampersands included — stays a
valid string, and Vue escapes it in the page.

**The site's CI is on from its first commit.** `ci.yml` used to wait for an
`ORUN_CI` repository variable, which a bootstrap has no way to set. It now
plans nothing only while `intent.yaml` names the placeholder `ws_CHANGE_ME`,
which this repository carries and no site does. `checks.yml` runs on pull
requests only, so `ci.yml` is the one run a push to main has (risks NB-K).

**Testing without the platform.** `testing/lib/bootstrap.sh` places every
phase and runs the blueprint's own `run:` hooks, read out of the document, so
the whole bootstrap short of the platform's typed actions runs in CI on every
pull request; `testing/e2e.test.sh` then builds the site in a job tree staged
as orun stages it, dry-deploys it, serves it with `wrangler dev` over the
committed `wrangler.jsonc`, and runs the component's own smoke against it.
