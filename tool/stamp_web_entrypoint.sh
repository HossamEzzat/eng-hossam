#!/usr/bin/env bash
# Post-process Flutter web build so browsers/SWs cannot keep serving a stale
# main.dart.js (users were stuck on 1.0.9 showing "after attendance approval").
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB="$ROOT/build/web"
STAMP="${1:-instantcert16}"
ENTRY="main.${STAMP}.js"

if [[ ! -f "$WEB/main.dart.js" ]]; then
  echo "missing $WEB/main.dart.js — run flutter build web first" >&2
  exit 1
fi

cp -f "$WEB/main.dart.js" "$WEB/$ENTRY"
# Keep original too, but bootstrap will load the stamped name only.
if [[ -f "$WEB/flutter_bootstrap.js" ]]; then
  # Replace mainJsPath inside the embedded buildConfig JSON.
  perl -i -pe "s/\"mainJsPath\":\"main\\.dart\\.js\"/\"mainJsPath\":\"${ENTRY}\"/" \
    "$WEB/flutter_bootstrap.js"
fi

# Kill-switch service worker (never cache the app shell).
cp -f "$ROOT/web/flutter_service_worker.js" "$WEB/flutter_service_worker.js"

echo "Entrypoint stamped as $ENTRY"
