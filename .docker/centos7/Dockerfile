from centos:7

run yum install -y git
RUN mkdir /etc/nix && touch /etc/nix/nix.conf
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
  && echo "filter-syscalls = false" >> /etc/nix/nix.conf
run cat /etc/nix/nix.conf
run bash -c "sh <(curl -L https://nixos.org/nix/install) --daemon"
run bash -ic "nix --version"
run bash -ic 'nix-shell -p nix-info --run "nix-info -m"'
run bash -ic 'nix-shell -p neovim'
run bash -ic 'nix-shell -p neovim --run "nvim --version"'
