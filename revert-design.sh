bash revert-design.sh#!/bin/bash
# =====================================================================
# TMSK revert
# Undoes design changes that are NOT on GitHub (origin/main) yet.
#
# HOW TO USE
#   cd /workspaces/kebang-website
#   bash revert-design.sh
# It shows exactly what would be thrown away and asks you to choose.
# It also saves a safety copy first, so even a revert can be undone.
# Only works for changes that were not pushed. After a push, use:
#   git revert HEAD && git push
# =====================================================================

ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$ROOT" ]; then
  echo "Run this inside /workspaces/kebang-website"
  exit 1
fi
cd "$ROOT" || exit 1

git fetch origin main --quiet 2>/dev/null
if ! git rev-parse --verify origin/main >/dev/null 2>&1; then
  echo "Could not find origin/main. Check your internet connection and try again."
  exit 1
fi

UNPUSHED=$(git log origin/main..HEAD --oneline)
CHANGED=$(git status --short)

if [ -z "$UNPUSHED" ] && [ -z "$CHANGED" ]; then
  echo "Nothing to revert. Your files already match origin/main."
  exit 0
fi

echo "================ WHAT IS NOT ON GITHUB YET ================"
echo ""
echo "Saved (committed) here but not pushed:"
if [ -n "$UNPUSHED" ]; then echo "$UNPUSHED"; else echo "  (none)"; fi
echo ""
echo "Edited or new files that are not committed:"
if [ -n "$CHANGED" ]; then echo "$CHANGED"; else echo "  (none)"; fi
echo ""
echo "==========================================================="
echo "What do you want to do?"
echo "  1) Undo only the edits that are not committed (keeps your unpushed commits)"
echo "  2) Undo everything above and go back exactly to what is on GitHub"
echo "  3) Cancel"
read -r -p "Type 1, 2 or 3: " CHOICE

STAMP=$(date +%Y%m%d-%H%M%S)
SAFE="/tmp/revert-safety-$STAMP"
mkdir -p "$SAFE"

case "$CHOICE" in
  1)
    git diff HEAD > "$SAFE/uncommitted-changes.patch"
    git reset --hard HEAD
    git clean -fd -e '*.sh' -e 'design-files*.txt'
    ;;
  2)
    git branch "backup-before-revert-$STAMP" HEAD
    git diff HEAD > "$SAFE/uncommitted-changes.patch"
    git reset --hard origin/main
    git clean -fd -e '*.sh' -e 'design-files*.txt'
    ;;
  *)
    echo "Nothing changed."
    exit 0
    ;;
esac

echo ""
echo "Reverted."
echo "Safety copy of the edits you threw away: $SAFE/uncommitted-changes.patch"
if [ "$CHOICE" = "2" ]; then
  echo "Your unpushed commits are kept on the branch: backup-before-revert-$STAMP"
fi
echo ""
git status --short
echo "Check the site:  npm run dev -- --host"
