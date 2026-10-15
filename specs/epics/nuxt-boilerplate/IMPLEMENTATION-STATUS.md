# nuxt-boilerplate (NB) — Implementation status

As-built ≠ intent. This file records what actually shipped, and every place
the code departed from `design.md` or from the upstream template.

| Milestone | State | PR |
|---|---|---|
| NB0 — the spec | | |
| NB1 — the site on Workers | | |
| NB2 — ready to instantiate | | |

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
