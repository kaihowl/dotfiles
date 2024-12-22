.PHONY: full minimal clean closuresize-all closuresize-single print-dependencies
 
full:
	nix run home-manager/release-24.05 -- --impure switch --flake .#full --show-trace

minimal:
	nix run home-manager/release-24.05 -- --impure switch --flake .#minimal

clean:
	nix-collect-garbage -d

closuresize-all:
	nix path-info -S ~/.nix-profile/ -r | sort -n -k2

closuresize-single:
	nix path-info -S ~/.nix-profile/

print-dependencies:
	nix-store --query ~/.nix-profile --graph | dot -Tpdf -o out.pdf && open out.pdf
