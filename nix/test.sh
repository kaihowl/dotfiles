#!/usr/bin/env -S zsh -il

# Check that no sources have to be pulled after the GC run done as part of the install.

output_log_file=$(mktemp)
nix run -L --log-format raw --verbose --impure .#home-manager -- --impure switch --flake .#full 2>&1 | tee "${output_log_file}"
if grep -Ei '\b(download|copy|nixos\.org|github\.com)\b' "$output_log_file"; then
  echo 'Unexpected downloads during reinstall after GC'
  exit 1
fi

