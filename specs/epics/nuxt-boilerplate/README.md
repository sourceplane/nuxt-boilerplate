# Epic: nuxt-boilerplate (NB)

**Vercel's Nuxt boilerplate is one file — `app.vue` rendering `<NuxtWelcome />` — with the index route pre-rendered, and Nuxt's server is Nitro, which ships its own Cloudflare Workers preset. Naming that preset is the whole port; the app does not change. What the repository adds is the Cirrus baseline shape around it: an Orun intent, a component that deploys the Worker Nitro emits and the assets beside it, a credential-free checks lane, and an Orun lane that turns on when the product is linked.**

This is the second port without OpenNext, on the shape astro-boilerplate set for frameworks with a native Cloudflare target: the `cloudflare-workers-assets-turbo` component takes the Worker entrypoint plus the assets directory the framework emits. The template is three years old (Nuxt 3.8); the port runs the current Nuxt (4).

## Status

| Field | Value |
|-------|-------|
| Status | ✅ Shipped — NB0–NB2 landed (#1, #2, #3) |
| Cluster | **NB** (NB0–NB2) |
| Owner(s) | `apps/web` (the site, with its `@nuxt/test-utils` test) |
| Builds on | `cirrus-baseline` conventions; the `astro-boilerplate` port's repository shape |
| Upstream | [vercel/examples `framework-boilerplates/nuxtjs`](https://github.com/vercel/examples/tree/main/framework-boilerplates/nuxtjs) |
| Changes | Nitro preset `cloudflare_module` (with its generated config off), Nuxt 3.8 → 4; `app.vue`, the route rules and the public assets are untouched |
| Decisions locked | (1) Nitro's Cloudflare Workers preset, not OpenNext (Nuxt is not Next) and not Cloudflare Pages. (2) The committed `wrangler.jsonc` is the deployable config; Nitro's `deployConfig` is off. (3) `app.vue` stays at the root — Nuxt 4 keeps the root as `srcDir` when there is no `app/` directory. (4) Tests live in the app (`@nuxt/test-utils` needs Nuxt's Vite config and auto-imports). (5) Nuxt 4 (current major; the template floats `^3.8`). |
| Gate | NB1 is the first user-visible rung. |
| Shipped as | `main` after [#3](https://github.com/sourceplane/nuxt-boilerplate/pull/3); verified locally under `wrangler dev`, deploy gated until a workspace is linked |

## Read order

1. `design.md` — what maps to what, the build, what is out of scope
2. `implementation-plan.md` — the milestones and what "done" means for each
3. `risks-and-open-questions.md` — what could go wrong and what was decided
4. `IMPLEMENTATION-STATUS.md` — what actually shipped (kept distinct from intent)

## Milestones at a glance

| Milestone | What it lands | Done when |
|---|---|---|
| NB0 — the spec | this doc set and the task contracts | merged on `main` |
| NB1 — the site on Workers | `apps/web` on Nuxt 4 with the Cloudflare preset, a test, green checks | `wrangler dev` serves the welcome page; Checks green |
| NB2 — ready to instantiate | README, as-built status | a reader can run, test, preview and deploy it |
