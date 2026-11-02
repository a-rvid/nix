{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    age
    alacritty
    btop
    curl
    fd
    file
    fuzzel
    git
    grim
    gnupg
    jq
    man-pages
    neovim
    nh
    ripgrep
    slurp
    sops
    stow
    tree
    unzip
    wget
    wl-clipboard
  ];

  programs.git.enable = true;
  programs.firefox.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
