#/bin/zsh
nix-env -iA \
        nixpkgs.neovim \
        nixpkgs.git \
        nixpkgs.tmux \
        nixpkgs.stow \
        nixpkgs.fzf \
        nixpkgs.ripgrep \
        nixpkgs.zoxide \
        nixpkgs.kanata
./jetbrains-nerd-font.sh
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
