#!/usr/bin/env bash
set -euo pipefail

host="${1:-}"
adopt=()

if [[ -z "$host" ]]; then
  echo "usage: $0 <host> [--adopt]" >&2
  exit 2
fi

if [[ "${2:-}" == "--adopt" ]]; then
  adopt=(--adopt)
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home_dir="${HOME:?HOME is not set}"

packages=(common)
if [[ -d "$repo_root/home/$host" ]]; then
  packages+=("$host")
fi

exec stow --no-folding --restow --verbose=1 \
  --dir "$repo_root/home" \
  --target "$home_dir" \
  "${adopt[@]}" \
  "${packages[@]}"
