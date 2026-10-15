# nuxt-boilerplate — implementation plan

Milestones land in order; each task is one pull request on an
`orun/NB-n-<slug>` branch with an `Orun-Task: NB-n` trailer.

## NB0 — the spec ✅

This doc set, `epic.yaml` and the task contracts, merged to `main`.

**Done when**
- the five documents and `epic.yaml` are on `main`
- `tasks/NB-1..NB-3.TaskContract.yaml` exist (NB-4 joined with NB3)

## NB1 — the site on Workers ✅

`apps/web` is the upstream boilerplate on Nuxt 4 with Nitro's
`cloudflare_module` preset, the committed `wrangler.jsonc`, and one
`@nuxt/test-utils` test.

**Done when**
- `pnpm install && pnpm typecheck && pnpm lint && pnpm test && pnpm build` is green locally and in `Checks`
- `wrangler dev --config wrangler.jsonc` answers `/` (200, the welcome page titled "Welcome to Nuxt!"), `/favicon.ico` and a `/_nuxt/*.js` chunk (200), `/_payload.json` (200)

## NB2 — ready to instantiate ✅

README (run, test, preview, deploy), `IMPLEMENTATION-STATUS.md`, epic
`completed`.

**Done when**
- the README quick start works from a fresh clone
- the status file lists every PR and departure

## NB3 — a baseline 🟡

`blueprint.yaml`, `repo-blueprint.yaml`, `.baseline/` (identity, task
contracts, the site's README), the `siteName` seam in `apps/web/app.config.ts`,
`tooling/rebrand`, `tooling/bootstrap`, `hooks/render-deployment-docs.sh`,
`ai/context/`, `docs/phases/`, `BOOTSTRAP.md`, `testing/`, `baseline.yml` and
`tag.yml` (design §6) — ported from portfolio-starter-kit's `baseline-v2`,
with what its first live bootstrap found already in.

**Done when**
- orun at the bootstrap floor (v2.58.11) and at the lane pin (v2.78.4) reads
  `repo-blueprint.yaml`, and `testing/manifest.test.sh` holds the card to it
- `Baseline CI` is green: the contract tests, the leak gate, the offline
  bootstrap (`testing/placement.test.sh`) and the end-to-end tier
  (`testing/e2e.test.sh`, in a staged job tree)
- the status file records what is proven offline and what only a live
  bootstrap can prove

## After NB3 (outside this repository)

1. Cut `baseline-v1` with `tag.yml` from the merged `main`.
2. Register the row in orun-cloud's `infra/baselines-registry/baselines.yaml`
   (unlisted) with the card vendored at the tag.
3. Bootstrap one site from the tag against a workspace; record its timings;
   then flip the row to public with a page on orunbase.com.

## Sequencing note

NB1 needs only NB0's contracts; NB2 is documentation over NB1's verified
build; NB3 packages NB1's site as a baseline. Deploying is the gated Orun
lane, not a milestone.
