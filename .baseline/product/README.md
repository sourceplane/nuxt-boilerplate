# nuxt-boilerplate

A Nuxt site — Nuxt 4 with the welcome page pre-rendered and Nitro's server
behind it — on **Cloudflare Workers + Static Assets** through Nitro's own
[`cloudflare_module`](https://nitro.build/deploy/providers/cloudflare) preset.

## Live deployment

<!-- 03-docs:begin -->
Not recorded yet. The bootstrap's last phase writes the live URLs, the
workspace and the secrets inventory into
[ai/context/deployment.md](ai/context/deployment.md); how the site deploys
and how to operate it is in
[ai/context/operations.md](ai/context/operations.md).
<!-- 03-docs:end -->

## What is here

| Surface | Where |
|---|---|
| The site's name (the page title) | `apps/web/app.config.ts` |
| `/`, pre-rendered: `<NuxtWelcome />`. There is no `pages/` directory, so every other path renders the same `app.vue`, in the Worker | `apps/web/app.vue` |
| Nitro preset and route rules | `apps/web/nuxt.config.ts` |
| Workers build and deploy contract | `apps/web/wrangler.jsonc`, `apps/web/component.yaml` |
| Tests (`@nuxt/test-utils`, `mountSuspended`) | `apps/web/test` |

## Getting started

```bash
pnpm install          # runs `nuxt prepare`
pnpm typecheck        # nuxt typecheck (vue-tsc)
pnpm lint
pnpm test             # vitest in the nuxt environment
pnpm build            # nuxt build → apps/web/.output/server (the Worker) + .output/public (the assets)
```

```bash
pnpm --filter @app/web dev        # http://localhost:3000
pnpm --filter @app/web preview    # wrangler dev over the built Worker
```

Make the site yours in `apps/web/app.vue`: replace `<NuxtWelcome />` with
your own code, and add a `pages/` directory when you want routes (Nuxt then
brings its router, and an unknown path becomes its 404 page). The site's
name — today, the page title — is `siteName` in `apps/web/app.config.ts`;
read it anywhere with `useAppConfig()`.

## How it deploys

Merges to `main` converge through Orun: `.github/workflows/ci.yml` plans the
changed components and runs each lane against the workspace in
`intent.yaml`. The site deploys to `stage`, then to `prod` once stage has
converged on the same commit; `dev` only verifies. The Worker is
`nuxt-boilerplate-web-<env>` on your account's workers.dev subdomain, and
every deploy is smoke-tested over HTTP: the home page must be the Nuxt app,
and a path no static asset matches must be answered by the Worker.
`checks.yml` runs install, typecheck, lint, test and build on every pull
request. (A push to `main` runs `ci.yml` alone, which builds and deploys.)

The pipeline holds one credential, GitHub's own `GITHUB_TOKEN`. The
Cloudflare token and account id are brokered per run from the workspace's
Cloudflare connection; nothing provider-shaped is stored in the repository
or in GitHub.

## Custom domain

The site answers on workers.dev from its first deploy. To serve it on your
own domain:

1. Add the domain to the Cloudflare account the site deploys into, and attach
   it to the Worker (dashboard → Workers & Pages →
   `nuxt-boilerplate-web-prod` → Settings → Domains & Routes → Add →
   Custom domain). Do the same for stage with a subdomain if you want one.
2. Set the environment's `url` in `intent.yaml` to it, so the platform links
   the address visitors use:

   ```yaml
   environments:
     prod:
       url: https://nuxt-boilerplate.example.com
   ```

The pages carry no absolute links to their own origin, so nothing needs
rebuilding: the domain answers as soon as Cloudflare attaches it.
