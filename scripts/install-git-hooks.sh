#!/usr/bin/env bash
set -euo pipefail

HOOK_DIR=".git/hooks"
POST_MERGE="$HOOK_DIR/post-merge"
mkdir -p "$HOOK_DIR"

cat > "$POST_MERGE" <<'SH'
#!/usr/bin/env bash
set -e
changed_files=$(git diff --name-only HEAD@{1} HEAD || true)
if echo "$changed_files" | grep -qE '(^|/)requirements\.txt$'; then
  echo "[post-merge] requirements.txt changed -> make setup"
  if command -v make >/dev/null 2>&1; then
    make setup || true
  fi
fi
if echo "$changed_files" | grep -qE '(^|/)Brewfile$'; then
  echo "[post-merge] Brewfile changed -> brew bundle"
  if command -v brew >/dev/null 2>&1; then
    brew bundle || true
  fi
fi
SH

chmod +x "$POST_MERGE"
echo "Installed post-merge hook at $POST_MERGE"
