# nuxt-boilerplate

Vercel's [Nuxt boilerplate](https://github.com/vercel/examples/tree/main/framework-boilerplates/nuxtjs)
— `app.vue` rendering the Nuxt welcome page, with the index route
pre-rendered — running on **Cloudflare Workers + Static Assets** through
Nitro's own [`cloudflare_module`](https://nitro.build/deploy/providers/cloudflare)
preset, inside the repository conventions of the
[Cirrus baseline](https://github.com/sourceplane/cirrus-baseline).

Naming the Nitro preset is the whole port; the app does not change. See
[`specs/epics/nuxt-boilerplate`](specs/epics/nuxt-boilerplate/README.md)
for the design, the milestones and the as-built status.

## What is here

| Surface | Where |
|---|---|
| `/` (pre-rendered): `<NuxtWelcome />` — the template has no `pages/`, so every other path renders the same `app.vue` | `apps/web/app.vue` |
| Nitro preset and route rules | `apps/web/nuxt.config.ts` |
| Worker config, deploy contract | `apps/web/wrangler.jsonc`, `apps/web/component.yaml` |
| Test (`@nuxt/test-utils`, `mountSuspended`) | `apps/web/test` |

## Getting started

```bash
pnpm install          # runs `nuxt prepare`
pnpm typecheck        # nuxt typecheck (vue-tsc)
pnpm test             # vitest in the nuxt environment
pnpm build            # nuxt build → apps/web/.output/server (Worker) + .output/public (assets)
```

```bash
pnpm --filter @app/web dev        # http://localhost:3000
pnpm --filter @app/web preview    # wrangler dev over the built Worker
```

## How it maps to Vercel

| Vercel | Here |
|---|---|
| Zero-config Nuxt hosting (Nitro's `vercel` preset, chosen by the platform) | Nitro's `cloudflare_module` preset, named in `nuxt.config.ts`: Worker under `.output/server/`, static output under `.output/public/` |
| The pre-rendered `/` (`routeRules`) served from Vercel's CDN | `.output/public/index.html` (and `_payload.json`), served by Static Assets ahead of the Worker |
| Node.js serverless runtime | `nodejs_compat` on the Worker; Nitro bundles its Node-compat shims |
| Deploy on push | Orun deploys `nuxt-boilerplate-web-{stage,prod}` on merge to `main` |

## Deploying

`.github/workflows/checks.yml` runs install, typecheck, lint, test and build
on every push and pull request. `ci.yml` is the Orun pipeline: set
`execution.state.workspace` in `intent.yaml` to this product's workspace
(`orun cloud link`), connect a Cloudflare account to it, and set the
`ORUN_CI` repository variable to `true`. A merge to `main` then deploys the
Worker to `stage`, then `prod`.
