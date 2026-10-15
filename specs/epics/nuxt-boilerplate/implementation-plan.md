# nuxt-boilerplate — implementation plan

Milestones land in order; each task is one pull request on an
`orun/NB-n-<slug>` branch with an `Orun-Task: NB-n` trailer.

## NB0 — the spec

This doc set, `epic.yaml` and the task contracts, merged to `main`.

**Done when**
- the five documents and `epic.yaml` are on `main`
- `tasks/NB-1..NB-3.TaskContract.yaml` exist

## NB1 — the site on Workers

`apps/web` is the upstream boilerplate on Nuxt 4 with Nitro's
`cloudflare_module` preset, the committed `wrangler.jsonc`, and one
`@nuxt/test-utils` test.

**Done when**
- `pnpm install && pnpm typecheck && pnpm lint && pnpm test && pnpm build` is green locally and in `Checks`
- `wrangler dev --config wrangler.jsonc` answers `/` (200, the welcome page titled "Welcome to Nuxt!"), `/favicon.ico` and a `/_nuxt/*.js` chunk (200), `/_payload.json` (200)

## NB2 — ready to instantiate

README (run, test, preview, deploy), `IMPLEMENTATION-STATUS.md`, epic
`completed`.

**Done when**
- the README quick start works from a fresh clone
- the status file lists every PR and departure

## Sequencing note

NB1 needs only NB0's contracts; NB2 is documentation over NB1's verified
build. Deploying is the gated Orun lane, not a milestone.
