.PHONY: update clean
 
update:
	nix run home-manager/release-24.05 -- --impure switch --flake .#myprofile

clean:
	nix-collect-garbage -d

closuresize-all:
	nix path-info -S ~/.nix-profile/ -r | sort -n -k2

closuresize-single:
	nix path-info -S ~/.nix-profile/

print-dependencies:
	nix-store --query ~/.nix-profile --graph | dot -Tpdf -o out.pdf && open out.pdf
