# nuxt-boilerplate

Vercel's [Nuxt boilerplate](https://github.com/vercel/examples/tree/main/framework-boilerplates/nuxtjs)
— `app.vue` rendering the Nuxt welcome page, with the index route
pre-rendered — running on **Cloudflare Workers + Static Assets** through
Nitro's own [`cloudflare_module`](https://nitro.build/deploy/providers/cloudflare)
preset, and packaged as an **Orun baseline**: one command takes a new site
from nothing to live on stage and prod, in its own repository, under its own
name.

Naming the Nitro preset is the whole port; the app does not change, except
that its page title now reads the site's name from one place
(`apps/web/app.config.ts`). What the baseline adds is everything needed to
make a copy of it somebody else's — built the way
[cirrus-baseline](https://github.com/sourceplane/cirrus-baseline) is. See
[`specs/epics/nuxt-boilerplate`](specs/epics/nuxt-boilerplate/README.md)
for the design, the milestones and the as-built status.

## Instantiating a site

```bash
git clone --depth 1 --branch <baseline-tag> https://github.com/sourceplane/nuxt-boilerplate
cd nuxt-boilerplate
orun new --blueprint repo-blueprint.yaml --out ~/sites/acme-notes --run-hooks --resume \
  --set reponame=acme-notes --set productname="Acme Notes" --set productdomain=acme.dev \
  --set githuborg=acme-inc --set subdomain=<workers-dev-subdomain>
```

Or, once the platform's registry lists it, from the Orun console (Baselines →
`nuxt-boilerplate` → Build). Three phases — `01-scaffold` (the repository,
its CI and identity), `02-site` (the site deployed to stage and prod,
smoke-tested), `03-docs` (the live deployment recorded) — each landing one
pull request in the new repository. **[BOOTSTRAP.md](BOOTSTRAP.md)** is the
operator guide; [docs/phases/](docs/phases/README.md) has a page per phase.

The new repository receives the **site only** — the app and its tests, its
CI, its tooling, a README of its own and its operating contract — renamed
throughout to the site's name, repository and Cloudflare Worker. None of this
repository's machinery ships.

| What makes it a baseline | Where |
|---|---|
| The console card (inputs, secrets, programme) | `blueprint.yaml` |
| The build document (modules, phases, hooks) | `repo-blueprint.yaml` |
| This tree's identity, and the bootstrap's task contracts | `.baseline/` |
| The rename engine | `tooling/rebrand/rebrand.mjs` |
| The bootstrap's helpers (deferrals, redeploy marker, work-tree strip) | `tooling/bootstrap/` |
| The deployment-record renderer | `hooks/render-deployment-docs.sh` |
| The site's README and context pack | `.baseline/product/README.md`, `ai/context/` |
| The baseline's tests: contract, leak, offline bootstrap, end to end | `testing/`, `.github/workflows/baseline.yml` |
| Cutting a `baseline-vN` tag | `.github/workflows/tag.yml` |

## What is here (the site)

| Surface | Where |
|---|---|
| The site's name (the page title reads it) | `apps/web/app.config.ts` |
| `/` (pre-rendered): `<NuxtWelcome />` — the template has no `pages/`, so every other path renders the same `app.vue`, in the Worker | `apps/web/app.vue` |
| Nitro preset and route rules | `apps/web/nuxt.config.ts` |
| Worker config, deploy contract | `apps/web/wrangler.jsonc`, `apps/web/component.yaml` |
| Tests (`@nuxt/test-utils`, `mountSuspended`) | `apps/web/test` |

## Getting started

```bash
pnpm install          # runs `nuxt prepare`
pnpm typecheck        # nuxt typecheck (vue-tsc)
pnpm lint
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
| Deploy on push | Orun deploys `<repo>-web-{stage,prod}` on merge to `main` (`apps/web/component.yaml`) |
| "Deploy with Vercel" (clone the template) | `orun new --blueprint repo-blueprint.yaml` — a new repository, branded, deployed |

## CI

| Workflow | What it runs | Ships to a site |
|---|---|---|
| `checks.yml` | install, wire fixtures, typecheck, lint, test, build — every PR (not pushes: on main, `ci.yml` must be the only run a commit has, because the bootstrap's convergence watch takes the newest one) | yes |
| `ci.yml` | the Orun pipeline: `orun plan --changed`, then one job per lane; deploys stage → prod on merge. It plans nothing while `intent.yaml` names the placeholder workspace `ws_CHANGE_ME`, as this repository does | yes |
| `baseline.yml` | the baseline's own tiers: contract tests, the blueprint read by the pinned orun, the leak gate, the offline bootstrap, the site built in a staged job tree, dry-deployed and served | no |
| `tag.yml` | cuts a `baseline-vN` tag (manual) | no |
