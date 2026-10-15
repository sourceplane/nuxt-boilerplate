# nuxt-boilerplate (NB) — Implementation status

As-built ≠ intent. This file records what actually shipped, and every place
the code departed from `design.md` or from the upstream template.

| Milestone | State | PR |
|---|---|---|
| NB0 — the spec | ✅ Shipped | [#1](https://github.com/sourceplane/nuxt-boilerplate/pull/1) |
| NB1 — the site on Workers | ✅ Shipped | [#2](https://github.com/sourceplane/nuxt-boilerplate/pull/2) |
| NB2 — ready to instantiate | ✅ Shipped | [#3](https://github.com/sourceplane/nuxt-boilerplate/pull/3) |

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

## Verified

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
