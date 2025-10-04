{
  homebrew = {
    enable = true;
    global.brewfile = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = false;
    };
    caskArgs = {
      require_sha = false;
      no_quarantine = true;
    };
    brews = [
      # ai
      "gemini-cli"
      "opencode"
      # container
      "docker"
      "docker-credential-helper"
      "colima"
      # ios
      "cocoapods"
      "xcode-build-server"
      # rails
      "libpq"
      "libyaml"
      # postgres
      "postgresql@16"
    ];
    casks = [
      "bruno"
      "dbeaver-community"
      "ente-auth"
      "firefox"
      "ghostty"
      "iina"
      "localsend"
      "postman"
      "slack"
      "visual-studio-code"
      "wezterm@nightly"
      "zed"
      "zoom"
      # ai
      "claude-code"
    ];
    taps = [
      "sst/tap"
    ];
  };
}
