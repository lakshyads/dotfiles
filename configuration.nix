{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };


  nix-homebrew = {
    enable = true;
    inherit user;
    # This Mac already has a native Homebrew install. autoMigrate lets
    # nix-homebrew adopt it: it deletes and recreates Homebrew's own
    # management directory (the `brew` tool + git metadata), but leaves
    # already-installed formulae/casks (Cellar/Caskroom) untouched.
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    # Start at "none", not "zap": undeclared casks/formulae are left alone
    # rather than force-uninstalled. Only consider "zap" once `brew list`
    # has been verified to match this list exactly after a few switches.
    onActivation.cleanup = "none";

    taps = [
      "hashicorp/tap"
      "stripe/stripe-cli"
      "kunchenguid/tap"
    ];

    # Every CLI tool lives here, not in Nix, so `brew upgrade <tool>` on the
    # spot and ./update.sh converge on the same state. Activation only
    # installs what's missing — it never downgrades a tool you upgraded.
    # Their config stays declarative in home.nix (starship.toml, git, zsh).
    brews = [
      # asdf + runtime build-support libs
      "asdf"
      "coreutils"
      "openssl@3"
      "readline"
      "xz"
      # Shell & modern CLI
      "starship"
      "zoxide"
      "atuin"
      "fzf"
      "ripgrep"
      "fd"
      "bat"
      "eza"
      "git-delta"
      "dust"
      "btop"
      "tlrc"            # binary: tldr (the `tldr` formula is disabled)
      "jq"
      "tree"
      "wget"
      # Git & editors
      "git"
      "gh"
      "lazygit"
      "neovim"
      "tree-sitter-cli" # CLI nvim-treesitter shells out to for compiling parsers
      # Agents & cloud
      "opencode"
      "herdr"           # agent multiplexer for the terminal (config in home/.config/herdr)
      "hashicorp/tap/terraform"
      "stripe/stripe-cli/stripe"
    ];

    casks = [
      # Containers
      "docker-desktop"
      # Cloud tooling
      "gcloud-cli"
      # Terminal emulators & editors
      "ghostty"
      "wezterm"
      "visual-studio-code"
      "cursor"
      # AI coding tools
      "claude"          # desktop app; the claude CLI uses Anthropic's native installer (bootstrap.sh)
      "codex"
      "codex-app"
      # Browsers
      "google-chrome"
      "firefox"
      "chatgpt-atlas"
      # Productivity & utilities
      "rectangle"
      "appcleaner"
      "maccy"
      "linearmouse"
      "opensuperwhisper"
      "obsidian"
      "kunchenguid/tap/baby-menu"  # agent-editable menu bar (https://github.com/kunchenguid/baby-menu)
      # API testing
      "granola"
      "postman"
      "whimsical"
    ];
  };
}
