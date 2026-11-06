#!/usr/bin/env bash
# Symlink user.js and chrome/*.css from this repo into LibreWolf's install-default profile.
# The profile folder name is random per machine, so it is read from profiles.ini instead of stowed.
# Existing real files are moved aside as *.pre-dotfiles. Safe to re-run.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
base="$HOME/Library/Application Support/LibreWolf"
rel="$(awk -F= '/^\[Install/{inst=1; next} /^\[/{inst=0} inst && $1=="Default"{print $2; exit}' "$base/profiles.ini")"
[ -n "$rel" ] || { echo "No install-default profile found in $base/profiles.ini" >&2; exit 1; }
profile="$base/$rel"
echo "Profile: $profile"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.pre-dotfiles"
    echo "  backed up $(basename "$dst") -> $(basename "$dst").pre-dotfiles"
  fi
  ln -s "$src" "$dst"
  echo "  linked $(basename "$dst")"
}

link "$here/profile/user.js" "$profile/user.js"
for f in "$here"/profile/chrome/*.css; do
  link "$f" "$profile/chrome/$(basename "$f")"
done
echo "Done. Restart LibreWolf to load the changes."
