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

## NB-G — No live bootstrap yet (OPEN)

Everything short of the platform is proven on every pull request: the card
against the build, the blueprint read by the pinned orun, the leak gate, the
offline bootstrap with the blueprint's own hooks, the site's own plan for the
02-site merge, and the produced site built in a staged job tree,
dry-deployed, served and smoke-tested. What is NOT proven is the platform's
half — the repository created and linked, the Cloudflare token minted by
`integrations/reconcile`, a real `wrangler deploy`, the probes against
workers.dev — and with it NB-C (`nodejs_compat` alone on the real runtime).
Hence the registry row stays `unlisted` until one bootstrap from the tag has
come up, as the portfolio baseline's did.

## NB-H — A custom domain is the owner's step (ACCEPTED)

Attaching a domain to a Worker needs zone-level permissions. The platform
brokers `workers-deploy` (Workers Scripts, KV, account read — no DNS) and
`dns-edit` only with zone ids, which a build does not have. The site's README
says how to attach one and record it as the environment's `url`; the pages
carry no absolute link to their own origin, so nothing is rebuilt for it, and
a re-run of `03-docs` probes the domain beside the workers.dev URL.

## NB-I — The name seam cannot live in `app/` (RESOLVED)

The portfolio baseline's seam is `apps/web/app/site.ts`. Here an `app/`
directory with any file in it makes Nuxt 4 take `app/` as its source root
(`@nuxt/schema`'s `srcDir` resolver), and the root `app.vue` is no longer the
app. The seam is `siteName` in `apps/web/app.config.ts` — Nuxt's own place
for public, build-time app configuration, typed from the file and read with
`useAppConfig()`. `apps/web/test/app.test.ts` mounts `app.vue` and checks
that the document title is that value, so a seam that stops being read fails
there; `testing/rebrand.test.sh` checks the rename writes any name the card
admits as a valid string.

## NB-J — Lane-shared installs (ACCEPTED: pinned to stack-tectonic 0.19.0)

The portfolio baseline's first live bootstrap died in `build-app` on
stack-tectonic 0.20.0, whose lane-scoped install links each job's top-level
`node_modules` out of its staged tree; Next 16's Turbopack refuses that. The
Nuxt build does not: built locally in a tree staged the 0.20.0 way
(`testing/lib/stage-job.py --shared-deps`), `nuxt build` and `wrangler deploy
--dry-run` both pass. It is pinned to 0.19.0 anyway — the site has one job per
lane (`lane: isolated`), so sharing the install saves nothing, a build whose
dependencies resolve outside its tree holds only while every tool in it agrees,
and the baselines stay on one composition. `testing/e2e.test.sh` builds in
whichever layout the pin plans, so a bump is tested, not assumed.

## NB-K — The convergence watch must see one workflow (RESOLVED, inherited)

`orun.run/watch@v1` with `sha:` takes the newest workflow run for the merge
commit from ANY workflow. The portfolio baseline's first live bootstrap
watched `checks.yml` go green while `ci.yml`'s deploy lanes had failed.
`checks.yml` here runs on pull requests (and by hand) only, so a push to main
starts `ci.yml` alone; `testing/coverage.test.sh` fails if a shipped workflow
other than `ci.yml` runs on push.

## NB-L — The smoke no longer greps the title (RESOLVED)

`smokeCommand` grepped `Welcome to Nuxt` — the `<title>` `<NuxtWelcome />`
set. The title is now the site's name, the owner's to change and
HTML-escaped when it carries `&` or `'`, so the smoke asks for what does not
change with it: the Nuxt app's `id="__nuxt"` root on `/`, and a 200 or 404 from
the Worker on a path no asset matches. The second request matters: `/` is the
pre-rendered index, which Static Assets serves without running the Worker, so
a Worker that throws on every request would pass a smoke of `/` alone. A 404
is accepted so the smoke still holds once a site adds `pages/` and Nuxt's
router answers unknown paths.
