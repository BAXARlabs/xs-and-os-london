#!/usr/bin/env bash
# Xs & Os of London — one-shot deploy script
# Runs from ~/Desktop/CLAUDE CODE/Projects/Xs and Os of London/xs-and-os-london/

set -e

REPO_NAME="xs-and-os-london"
GITHUB_ORG="BAXARlabs"

# --- sanity checks ---
echo "→ Checking prerequisites..."
command -v git >/dev/null || { echo "✗ git not installed"; exit 1; }
command -v gh  >/dev/null || { echo "✗ gh CLI not installed. Install with: brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "✗ gh CLI not authenticated. Run: gh auth login"; exit 1; }
echo "✓ git + gh CLI ready"

# --- script directory ---
cd "$(dirname "$0")"

# --- git init (idempotent) ---
if [ ! -d .git ]; then
  echo "→ Initialising git repo..."
  git init -b main >/dev/null
  git add .
  git commit -m "Initial: Xs & Os of London v7" >/dev/null
  echo "✓ initial commit"
else
  echo "✓ git repo already initialised"
  git add .
  git diff --cached --quiet || { git commit -m "Update site" >/dev/null && echo "✓ committed pending changes"; }
fi

# --- create GitHub repo + push (idempotent) ---
if ! gh repo view "$GITHUB_ORG/$REPO_NAME" >/dev/null 2>&1; then
  echo "→ Creating GitHub repo $GITHUB_ORG/$REPO_NAME..."
  gh repo create "$GITHUB_ORG/$REPO_NAME" --public --source=. --push --description "Fans' Ultimate Playbook to London — American football fan guide. Powered by Philly Sports Trips × Passyunk Avenue."
  echo "✓ pushed to github.com/$GITHUB_ORG/$REPO_NAME"
else
  echo "✓ GitHub repo already exists"
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$GITHUB_ORG/$REPO_NAME.git"
  git push -u origin main 2>/dev/null || echo "  (nothing to push)"
fi

# --- deploy to Vercel ---
echo ""
echo "→ Deploying to Vercel..."
echo ""
if command -v vercel >/dev/null; then
  vercel --prod --yes
else
  echo "Vercel CLI not installed. Install with:  npm install -g vercel"
  echo "Or import the repo via the dashboard:"
  echo "    https://vercel.com/new/import?s=https://github.com/$GITHUB_ORG/$REPO_NAME"
  exit 0
fi

echo ""
echo "✓ Done. Send the URL back to TARS to log it in the project note."
