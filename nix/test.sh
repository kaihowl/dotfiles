#!/usr/bin/env -S zsh -il

# Check that no sources have to be pulled after the GC run done as part of the install.

output_log_file=$(mktemp)
nix run -L --log-format raw --verbose --impure .#home-manager -- --impure switch --flake .#full 2>&1 | tee "${output_log_file}"
# Exclude cache.nixos.org downloads as they are expected (binary cache)
# Only fail if we're downloading sources from github.com or other source repos
if grep -Ei '\b(github\.com|gitlab\.com)\b' "$output_log_file" | grep -v 'cache\.nixos\.org'; then
  echo 'Unexpected source downloads during reinstall after GC'
  exit 1
fi

