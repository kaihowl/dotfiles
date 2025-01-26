.PHONY: full minimal clean closuresize-all closuresize-single print-dependencies
 
full:
	# TODO(kaihowl) twice impure
	nix run --impure .#home-manager -- --impure switch --flake .#full

minimal:
	nix run --impure .#home-manager -- --impure switch --flake .#minimal

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
