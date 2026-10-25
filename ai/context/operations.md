# nuxt-boilerplate — operating contract (for humans and agents)

This is the standing guide to how this site is deployed and operated.
Instance facts (live URLs, workspace, the secrets it uses) live in
[deployment.md](deployment.md), rendered from probed reality by the
bootstrap's `03-docs` phase; this file is the contract that stays true
between deployments. It is written to give an agent with repository read
access enough context to reason about and operate the site without any
other source.

## What this system is

A Nuxt site on Cloudflare alone, expressed as an Orun component-native
desired-state repo.

- **`apps/web`** — the site: Nuxt 4, built by Nitro's `cloudflare_module`
  preset into one Worker (`.output/server/index.mjs`) plus Static Assets
  (`.output/public`). The index route is pre-rendered at build time and
  served from the assets, with the hashed client bundle under `/_nuxt/`;
  every path no asset matches is rendered per request in the Worker. Its
  tests (`apps/web/test`, vitest under `@nuxt/test-utils`) are not run by
  any lane: a pull request builds and dry-deploys the site, so run `pnpm
  typecheck && pnpm lint && pnpm test` before you push. There is no
  database and no runtime secret.
- **`tooling/*`** — shared TypeScript and ESLint configuration, and the
  deploy-time wrangler renderer for workers that take wiring.

Environments: **`stage`** and **`prod`** are deployed; **`dev` is
verify-only by design** — lanes build, nothing deploys.

## Identity and tenancy

Every remote operation runs against ONE Orun workspace, declared in
`intent.yaml` under `execution.state.workspace` — committed, enforced, and
what CI uses. Do not remove it; headless credentials depend on it. If it
reads `ws_SET_ME`, the bootstrap had no workspace to write: set the real one
before anything else.

## How deployment works

1. Merge (or push) to `main`.
2. CI (`.github/workflows/ci.yml`) runs `orun plan --changed` — only
   components whose files changed are planned — then runs each planned lane
   with `orun run --remote-state`, authenticated by GitHub OIDC (the
   exchange resolves this repository's linked workspace server-side).
3. `apps/web` builds once per environment (`nuxt build` through turbo), then
   `wrangler deploy --config wrangler.jsonc` ships
   `nuxt-boilerplate-web-<env>` — the Worker and its assets in one upload —
   and a smoke test fetches `/` (the Nuxt app's root must be there) and a
   path no asset matches (the Worker must answer it, 200 or a 404 — never a
   5xx).
4. `prod` deploys after `stage` has converged on the same commit
   (`environments.prod.promotion` in intent.yaml).
5. **The convergence run is the deployment.** A green run means every
   planned lane applied. Failed lanes are retried with
   `gh run rerun --failed`, which resumes the same execution.

Caveats that matter:

- A push that touches no component files plans zero lanes — that run is
  green and deployed nothing. Never treat "latest run green" as "site
  converged"; probe the URLs instead.
- A change to `intent.yaml` alone maps to no component and redeploys
  nothing. Land it with a change under `apps/web` when it should.
- `apps/web/wrangler.jsonc` is the deployable config (Worker entry, assets
  directory, `nodejs_compat`, compatibility date). Nitro's own generated
  config is off (`nuxt.config.ts`, `cloudflare.deployConfig: false`), so
  there is one config, and it is the committed one.

## Secrets model

- **Brokered provider secrets**: `CLOUDFLARE_API_TOKEN` (Workers deploy
  scope) and `CLOUDFLARE_ACCOUNT_ID` — pointers minted per run from the
  workspace's Cloudflare connection. No long-lived values at rest; nothing
  to rotate by hand.
- Inspect by NAME only: `orun secrets list --org <ws> --project` and
  `--env stage|prod`. No tooling in this repository prints a secret value,
  and no document in `ai/context/` may contain one.
- The site needs no runtime secret.

## Verifying the system

```bash
# the site on each environment (also recorded, probed, in deployment.md)
curl -s -o /dev/null -w '%{http_code}\n' https://nuxt-boilerplate-web-stage.your-workers-subdomain.workers.dev/
curl -s https://nuxt-boilerplate-web-prod.your-workers-subdomain.workers.dev/ | grep -o '<title>[^<]*</title>'

# workspace readiness (integrations + repository link)
orun integrations list --org <ws> --json && orun cloud check --org <ws>
```

## Common operations

| task | how |
|---|---|
| rename the site | `siteName` in `apps/web/app.config.ts`, merge |
| replace the welcome page | edit `apps/web/app.vue` (add `pages/` for routes), merge |
| deploy a change | merge to `main`; watch the run; failed lanes → `gh run rerun --failed` |
| redeploy without a change | edit the last line of `apps/web/component.yaml` (`# orun: redeploy <reason> <stamp>`) and merge — it is a deploy trigger, nothing reads it |
| serve a custom domain | attach it to the Worker in Cloudflare and set the environment's `url` in `intent.yaml` (README, "Custom domain") |
| add a runtime secret | `orun secrets set <KEY> --org <ws> --env <env>` |
| headless credentials | `ORUN_TOKEN` (workspace-scoped) + `GITHUB_TOKEN` |

The deployment record is the bootstrap's `03-docs` phase. Re-running it (the
Orun console's Retry on that phase, or `orun new … --phase 03-docs`)
re-probes the URLs and re-renders [deployment.md](deployment.md); it is
idempotent.

## Evolution

Structural changes (a second Worker, an API, a data store) follow the same
contract that deployed the site: add a component under `apps/`, `infra/` or
`packages/` with a `component.yaml`, land it as a pull request, and the
convergence run applies it.
