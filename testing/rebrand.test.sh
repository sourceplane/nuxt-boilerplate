#!/usr/bin/env bash
# THE REBRAND WRITES EACH VALUE ONCE, AND WHAT IT WROTE STAYS WRITTEN.
#
# Drives the real tooling/rebrand/rebrand.mjs over one-file trees and compares
# the file. Each case is a shape this baseline's identity actually takes in the
# tree — the site-name seam, the worker name, the environment URL, the
# placeholder domain, a source link in the docs, a secret ref — and each runs
# through as many passes as a bootstrap makes (every phase re-runs the rebrand
# over everything already placed), so a value written by an early phase must
# survive every later one unchanged.
#
# The identity is PINNED (fixtures/baseline-identity.nuxt-boilerplate.json)
# rather than read from .baseline/identity.json: what this tests is the engine,
# and its fixtures spell the identity out literally.
#
# Needs: node, git. No network.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
rebrand="$here/../tooling/rebrand/rebrand.mjs"
identity="$here/fixtures/baseline-identity.nuxt-boilerplate.json"

fail=0
# check NAME VALUES-JSON FILE CONTENT WANT [PASSES]
check() {
  local name="$1" values="$2" file="$3" content="$4" want="$5" passes="${6:-1}"
  local tmp got out i
  tmp="$(mktemp -d)"
  git -C "$tmp" init -q
  mkdir -p "$tmp/$(dirname "$file")" "$tmp/.rebrand"
  printf '%s\n' "$content" > "$tmp/$file"
  printf '%s\n' "$values" > "$tmp/.rebrand/values.json"
  for ((i = 1; i <= passes; i++)); do
    git -C "$tmp" add -A
    if ! out="$(cd "$tmp" && node "$rebrand" --baseline-identity "$identity" --values .rebrand/values.json --allow-dirty 2>&1)"; then
      echo "   ✕  $name: rebrand pass $i failed:" >&2
      printf '%s\n' "$out" | sed 's/^/        /' >&2
      fail=1
      rm -rf "$tmp"
      return
    fi
  done
  got="$(cat "$tmp/$file")"
  rm -rf "$tmp"
  if [ "$got" = "$want" ]; then
    echo "   ok  $name"
  else
    echo "   ✕  $name:" >&2
    echo "        got:  $got" >&2
    echo "        want: $want" >&2
    fail=1
  fi
}

acme='{"reponame":"acme-notes","productname":"Acme Notes","productdomain":"acme.dev","githuborg":"acme-inc","subdomain":"acme","orunWorkspace":"ws_79BDXAZQ"}'

echo "── rebrand: the site's own identity"
check "the site-name seam takes the product's name" \
  "$acme" apps/web/app.config.ts '  siteName: "Nuxt Boilerplate",' \
  '  siteName: "Acme Notes",'
check "…and stays a valid string for a name with an apostrophe and an ampersand" \
  '{"reponame":"sams-notes","productname":"Sam'"'"'s Notes & Links","productdomain":"sam.dev"}' \
  apps/web/app.config.ts '  siteName: "Nuxt Boilerplate",' \
  '  siteName: "Sam'"'"'s Notes & Links",'
check "the display name elsewhere is content, and is left alone" \
  "$acme" apps/web/pages/about.vue '<p>Welcome to Nuxt Boilerplate.</p>' \
  '<p>Welcome to Nuxt Boilerplate.</p>'
check "a source link in the docs names the product's owner and repository" \
  "$acme" README.md \
  'Source: https://github.com/sourceplane/nuxt-boilerplate' \
  'Source: https://github.com/acme-inc/acme-notes'
check "the worker name is re-prefixed, the environment suffix kept" \
  "$acme" apps/web/component.yaml 'workerName: nuxt-boilerplate-web' \
  'workerName: acme-notes-web'
check "an environment URL: worker name and subdomain" \
  "$acme" intent.yaml \
  '    url: https://nuxt-boilerplate-web-stage.your-workers-subdomain.workers.dev' \
  '    url: https://acme-notes-web-stage.acme.workers.dev'
check "the placeholder domain is the product's domain, not a renamed slug" \
  "$acme" intent.yaml '      BASE_DOMAIN: nuxt-boilerplate.example.com' \
  '      BASE_DOMAIN: acme.dev'
check "the repo slug" \
  "$acme" package.json '  "name": "nuxt-boilerplate",' \
  '  "name": "acme-notes",'
check "a secret ref names the product's workspace and project" \
  "$acme" apps/web/component.yaml 'T: secret://ws_KWQ45Z6M/nuxt-boilerplate/stage/CLOUDFLARE_API_TOKEN' \
  'T: secret://ws_79BDXAZQ/acme-notes/stage/CLOUDFLARE_API_TOKEN'
check "org-owned identity is not renamed" \
  "$acme" intent.yaml 'apiVersion: sourceplane.io/v1 # mail ops@sourceplane.ai' \
  'apiVersion: sourceplane.io/v1 # mail ops@sourceplane.ai'
check "without githuborg a source link keeps the baseline's owner" \
  '{"reponame":"acme-notes","productname":"Acme Notes","productdomain":"acme.dev"}' \
  README.md 'Source: https://github.com/sourceplane/nuxt-boilerplate' \
  'Source: https://github.com/sourceplane/acme-notes'

echo "── rebrand: a written value is not rewritten, in any later pass"
contains='{"reponame":"nuxt-boilerplate-2","productname":"Nuxt Boilerplate 2","productdomain":"nuxt-boilerplate.example.com.au","githuborg":"sourceplane","subdomain":"your-workers-subdomain-2"}'
check "a repo slug containing the baseline's slug survives three passes" \
  "$contains" package.json '  "name": "nuxt-boilerplate",' \
  '  "name": "nuxt-boilerplate-2",' 3
check "a worker name built on it survives three passes" \
  "$contains" apps/web/component.yaml 'workerName: nuxt-boilerplate-web' \
  'workerName: nuxt-boilerplate-2-web' 3
check "a domain containing the baseline's domain survives three passes" \
  "$contains" intent.yaml 'BASE_DOMAIN: nuxt-boilerplate.example.com' \
  'BASE_DOMAIN: nuxt-boilerplate.example.com.au' 3
check "a subdomain containing the placeholder survives three passes" \
  "$contains" apps/web/component.yaml 'workersDevSubdomain: your-workers-subdomain' \
  'workersDevSubdomain: your-workers-subdomain-2' 3
check "a site name containing the baseline's name survives three passes" \
  "$contains" apps/web/app.config.ts '  siteName: "Nuxt Boilerplate",' \
  '  siteName: "Nuxt Boilerplate 2",' 3

# --verify runs in every phase. Without the product's values it cannot tell
# the product's own identity from a leftover; with them it can. A real
# leftover must fail it either way.
verify() { # NAME VALUES FILE CONTENT WANT(pass|fail) [--values]
  local name="$1" values="$2" file="$3" content="$4" want="$5" withvalues="${6:-}" tmp got
  tmp="$(mktemp -d)"
  git -C "$tmp" init -q
  mkdir -p "$tmp/$(dirname "$file")" "$tmp/.rebrand"
  printf '%s\n' "$content" > "$tmp/$file"
  printf '%s\n' "$values" > "$tmp/.rebrand/values.json"
  git -C "$tmp" add -A
  if (cd "$tmp" && node "$rebrand" --baseline-identity "$identity" --verify ${withvalues:+--values .rebrand/values.json} >/dev/null 2>&1); then got=pass; else got=fail; fi
  rm -rf "$tmp"
  if [ "$got" = "$want" ]; then echo "   ok  $name"; else echo "   ✕  $name: --verify ${got}ed, want $want" >&2; fail=1; fi
}
echo "── rebrand --verify: the product's own identity is not residue"
verify "given the values, a slug containing the baseline's passes" \
  "$contains" package.json '"name": "nuxt-boilerplate-2"' pass --values
verify "without them it cannot know, and fails" \
  "$contains" package.json '"name": "nuxt-boilerplate-2"' fail
verify "given the values, a real leftover still fails" \
  "$acme" package.json '"name": "nuxt-boilerplate"' fail --values
verify "a leftover worker name fails" \
  "$acme" apps/web/component.yaml 'workerName: nuxt-boilerplate-web' fail --values
verify "a leftover code identifier fails (no rule renames it — so nothing may spell it)" \
  "$acme" apps/web/utils/x.ts 'export class NuxtBoilerplate {}' fail --values
verify "a clean product passes" \
  "$acme" package.json '"name": "acme-notes"' pass --values

echo "── rebrand: a residue it cannot rename fails the rebrand itself"
tmp="$(mktemp -d)"; git -C "$tmp" init -q; mkdir -p "$tmp/.rebrand" "$tmp/apps/web"
printf '%s\n' "$acme" > "$tmp/.rebrand/values.json"
printf 'const x = "NUXT_BOILERPLATE_TOKEN"\n' > "$tmp/apps/web/x.ts"
git -C "$tmp" add -A
if (cd "$tmp" && node "$rebrand" --baseline-identity "$identity" --values .rebrand/values.json --allow-dirty >/dev/null 2>&1); then
  echo "   ✕  an unrenamable env-var prefix passed the rebrand" >&2; fail=1
else
  echo "   ok  an unrenamable env-var prefix fails the rebrand, naming the file"
fi
rm -rf "$tmp"

[ "$fail" -eq 0 ] || exit 1
echo "rebrand.test.sh: ok"
