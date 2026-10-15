# nuxt-boilerplate (NB) — Implementation status

As-built ≠ intent. This file records what actually shipped, and every place
the code departed from `design.md` or from the upstream template.

| Milestone | State | PR |
|---|---|---|
| NB0 — the spec | ✅ Shipped | [#1](https://github.com/sourceplane/nuxt-boilerplate/pull/1) |
| NB1 — the site on Workers | ✅ Shipped | [#2](https://github.com/sourceplane/nuxt-boilerplate/pull/2) |
| NB2 — ready to instantiate | ✅ Shipped | [#3](https://github.com/sourceplane/nuxt-boilerplate/pull/3) |
| NB3 — a baseline | 🟡 In progress | this PR (NB-4) |

## Departures from the upstream template

### Nitro's `cloudflare_module` preset, with `deployConfig` off

`nuxt.config.ts`: `nitro: { preset: 'cloudflare_module', cloudflare:
{ deployConfig: false } }`. Upstream names no preset (Vercel picks
`vercel`). The committed `wrangler.jsonc` (`main`, `assets`, `nodejs_compat`,
compatibility date 2026-10-01) is the deployable config; Nitro's generated
one is off.

### Nuxt 3.8 → 4.6

`nuxt ^3.8.2` → `^4.6.1`, `vue ^3.3.8` → `^3.5.44`, `vue-router ^4.2.5` →
`^5.4.0`, `@nuxt/devtools ^1.0.3` → `^3.4.3` (the versions Nuxt 4 pairs
with). `app.vue`, `nuxt.config.ts`'s `devtools` and `routeRules`, `public/`,
`server/tsconfig.json`, `tsconfig.json` and `postinstall: nuxt prepare` are
unchanged; the files stay at the root (Nuxt 4 keeps the root as `srcDir`
when there is no `app/` directory).

### Scripts

`preview` is `wrangler dev --config wrangler.jsonc` (upstream: `nuxt
preview`, which has no Workers runtime); `typecheck` and `lint` are `nuxt
typecheck` (vue-tsc); `test` is `vitest run`. `build`, `dev`, `generate` and
`postinstall` are upstream's.

### The app's `.gitignore` and lockfile are not copied

The repository's root `.gitignore` covers `.nuxt/` and `.output/`; the
workspace lockfile replaces the template's.

### `.nuxtrc` is git-ignored in the app

`@nuxt/test-utils` writes `setups.@nuxt/test-utils="<version>"` to
`apps/web/.nuxtrc` on its first run; the marker is not part of the
template and would churn on every upgrade, so `apps/web/.gitignore` keeps
it out.

### The page title is the site's name, from `app.config.ts` (NB3)

`app.vue` reads `siteName` from `app.config.ts` (`useAppConfig()`) and passes
it to `<NuxtWelcome :title>`; the welcome page's own title, "Welcome to
Nuxt!", is gone, and this repository's site is titled "Nuxt Boilerplate".
It is the seam the baseline's rename rewrites (risks NB-I). The welcome
page's body is untouched. `test/app.test.ts` gains a case that the document
title is `siteName`.

### `apps/web/README.md` is the app's, not the template's (NB3)

The upstream README advertised "Deploy with Vercel", a Vercel demo and Nuxt
3's documentation, and it ships into every site. It now describes the app
and credits the template (MIT).

## Departures from the port (NB3)

| What | Before | After | Why |
|---|---|---|---|
| `apps/web` smoke | `grep 'Welcome to Nuxt'` (the title) | `id="__nuxt"` on `/`, and a 200 or 404 from the Worker on `/__smoke` | the title is the owner's name now, and `/` alone never runs the Worker (risks NB-L) |
| `ci.yml` gate | `vars.ORUN_CI == 'true'` | skip only while `intent.yaml` names `ws_CHANGE_ME` | a bootstrap cannot set a repository variable |
| `checks.yml` triggers | push to main and pull requests | pull requests and `workflow_dispatch` | a push to main must start `ci.yml` alone (risks NB-K) |
| stack-tectonic | 0.18.2 | 0.19.0 | first-deploy and smoke retries (0.19.0); not 0.20.0's lane-shared install (risks NB-J) |
| orun lane pin | v2.78.0 | v2.78.4 | the portfolio and cirrus baselines' pin |
| `intent.yaml` | terraform `parameterDefaults`; docs pages under `specs/` | neither; docs pages `ai/context/*` | no terraform component; the pages must exist in a site |
| discovery roots | `infra/`, `packages/`, `tests/` absent | each carries a `.gitkeep` | `orun validate` fails on a missing root; `tests/` stays empty (the tests live in the app) |
| `.gitignore` | — | `node-compile-cache/` | Node's compile cache appeared in `apps/web` here once; the blueprint's `ignore` keeps it out of a site too |
| `tasks/NB-1..3` | no `metadata` | `metadata.name` and `title` | `orun work check` (≥ v2.79) refused them |

## Verified (NB3)

- `orun new --status` reads the blueprint at v2.58.11 (the bootstrap floor),
  v2.78.4 (the lane pin) and v2.79.0; `orun validate` and `orun work check`
  clean.
- `testing/{manifest,phases,coverage,rebrand,retouch,bootstrap-defer}.test.sh`
  green.
- `testing/leak.test.sh` (at v2.58.11, v2.78.4 and v2.79.0): 41 files
  derived; nothing of the factory, nothing local or built; no provenance
  prose.
- `testing/placement.test.sh` (at v2.58.11, v2.78.4 and v2.79.0; fixture
  "Sam's Notes & Links" / `acme-inc/acme-nuxt`): three landings; rebrand
  `--verify` clean;
  workspace re-tenanted, `work:` stripped, promotion and dev lanes restored;
  deployment record rendered; no tracked file names a factory path; the site's
  own `orun plan` for the 02-site merge deploys `web` to stage and prod side by
  side with the site's Worker name, smoke and secret refs; `--resume` changes
  nothing.
- `testing/e2e.test.sh` (at v2.78.4 and v2.79.0): the scaffold's landing and
  the finished site pass the Checks sequence; the stage lane's
  `install-workspace-dependencies`, `build-app`, `verify-build-output` and
  `deploy-dry-run` pass in a job tree staged as orun stages it; `wrangler dev`
  serves the built Worker from that tree; the component's own smoke passes,
  wrapped as the composition wraps it; `/` and a Worker-rendered path are the
  Nuxt app titled "Sam's Notes & Links", the `/_nuxt/` chunks carry the
  immutable caching of Nitro's `_headers`, `/_payload.json` and
  `/favicon.ico` answer.
- The same e2e with the pin moved to stack-tectonic 0.20.0 (lane-scoped
  install, `node_modules` linked out of the staged tree): green — the Nuxt
  build follows the link (risks NB-J).
- Not verified: a live bootstrap against a workspace (risks NB-G).

## Verified (NB1–NB2)

- Local: `nuxt typecheck` (0 errors), `pnpm test` (1 test, `mountSuspended`
  over `app.vue`), `pnpm build` green; `wrangler dev --config wrangler.jsonc`:
  `/` 200 (the welcome page, `<title>Welcome to Nuxt!</title>`),
  `/favicon.ico` 200, a `/_nuxt/*.js` chunk 200 (`text/javascript`),
  `/_payload.json` 200, `/nope` 200 with the same page (no `pages/`, no
  router, no 404 — as on Vercel). A fresh clone of #2's head:
  `pnpm install --frozen-lockfile`, typecheck, lint, test, build green.
- CI: `Checks` green on #1, #2 and on every push to `main`.
- Not verified: a live deploy (gated until the product is linked to an Orun
  workspace with a Cloudflare connection); the Worker on the real runtime
  with `nodejs_compat` alone, without Nitro's `no_nodejs_compat_v2` (NB-C).

## Versions

| Package | Version | Why |
|---|---|---|
| nuxt | ^4.6.1 | the current major; the template floats `^3.8.2` (November 2023) |
| nitropack | 2.13.4 (through `@nuxt/nitro-server`) | the `cloudflare_module` preset; its `deployConfig` is off |
| vue, vue-router | ^3.5.44, ^5.4.0 | what Nuxt 4.6 pairs with (the template: `^3.3.8`, `^4.2.5`) |
| @nuxt/devtools | ^3.4.3 | the template lists `^1.0.3`; Nuxt 4 bundles 3.x |
| @nuxt/test-utils, vitest, happy-dom, @vue/test-utils | ^4.3.3, ^5.0.4, ^21.0.1, ^2.5.1 | `mountSuspended` under the `nuxt` vitest environment (test-utils needs vitest ^4 or ^5) |
| vue-tsc | ^3.2.0 | `nuxt typecheck` |
| wrangler | ^4.151.0 | compatibility_date 2026-10-01 |
