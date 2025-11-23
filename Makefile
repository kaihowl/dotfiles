.PHONY: full minimal clean closuresize-all closuresize-single print-dependencies create-gc-root

full:
	@SYSTEM=$$(nix eval --impure --expr 'builtins.currentSystem' --raw); \
	nix run -L --log-format raw --verbose --impure .#home-manager -- switch --flake .#full-$$SYSTEM

minimal:
	@SYSTEM=$$(nix eval --impure --expr 'builtins.currentSystem' --raw); \
	nix run --impure .#home-manager -- switch --flake .#minimal-$$SYSTEM

checklicenses:
	nix flake check --impure 

clean:
	nix-collect-garbage -d

closuresize-all:
	nix path-info -S ~/.nix-profile/ -r | sort -n -k2

closuresize-single:
	nix path-info -S ~/.nix-profile/

print-dependencies:
	nix-store --query ~/.nix-profile --graph | dot -Tpdf -o out.pdf && open out.pdf

create-gc-root:
	nix develop --impure --profile ~/.nix-dotfiles-gc-root --command bash -c 'exit'
