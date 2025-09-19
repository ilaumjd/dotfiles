pkgs: {
  programs = {
    bash.enable = false;
    zsh.enable = true;
    fish.enable = true;
  };
  environment.shells = with pkgs; [
    # bash
    zsh
    fish
  ];
}
