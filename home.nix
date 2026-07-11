{ config, pkgs, user, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Modern CLI replacements & utilities not covered by a programs.* module
    ripgrep     # fast search
    fd          # fast find
    bat         # 
    lazygit
    eza         #
    btop
    delta
    dust
    tldr
    tmux
    neovim
    jq
    tree
    wget
    git
    gh
    opencode
    zsh-completions
    # Fonts — Hack is the primary system font (Ghostty/WezTerm); JetBrains
    # Mono and Fira Code stay installed as alternatives. See README.md
    # "Customization" for how to switch.
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
  fonts.fontconfig.enable = true;

  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history (replaces zsh-autosuggestions)
    syntaxHighlighting.enable = true;  # commands turn green when valid (replaces zsh-syntax-highlighting)
    enableCompletion = true;           # replaces zsh-completions plugin + manual compinit

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Modern CLI replacements
      ls = "eza --icons --group-directories-first";
      ll = "eza -lah --git --icons";
      # lt = full-depth tree listing; lt2 = capped at 2 levels (former lt default).
      lt = "eza --tree --icons";
      lt2 = "lt --level=2";
      lt3 = "lt --level=3";
      lt4 = "lt --level=4";
      lt5 = "lt --level=5";
      lt6 = "lt --level=6";
      lsa = "ls -a";
      lla = "ll -a";
      cat = "bat --paging=never";
      top = "btop";
      du = "dust";
      vi = "nvim";
      vim = "vi";

      # Git shortcuts
      g = "git";
      gs = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --oneline --graph --decorate -20";
      gla = "git log";
      lg = "lazygit";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";

      reload = "exec zsh";

      # High-agency agent shortcuts — opt-in, bypass permission prompts.
      cc = "claude";
      ccc = "claude --dangerously-skip-permissions";
      co = "codex";
      coo = "codex --full-auto";
      aa = "agent"; 
      aaa = "agent -f"; 
    };

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Homebrew PATH (Apple Silicon) — must come first; most tools live under /opt/homebrew.
        eval "$(/opt/homebrew/bin/brew shellenv)"

        # asdf shims — must come before any tool that might invoke node/python/go.
        export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

        # ~/.local/bin: user-installed tools not managed by Nix/Homebrew (e.g.
        # Cursor's `agent`/`cursor-agent` CLI, pip --user scripts). Appended
        # AFTER Homebrew's path on purpose — a stale ~/.local/bin/claude
        # symlink from Claude's old native installer lives here too, and it
        # must never shadow the current claude-code cask binary.
        export PATH="$PATH:$HOME/.local/bin"

        # zsh-completions extra definitions (git, docker, kubectl, etc.) — must load before compinit.
        fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
      '')
      ''
        # Ctrl+F accepts the current autosuggestion (ghost text from history).
       bindkey '^f' autosuggest-accept

        # fzf preview integration. Uses bat for file contents, eza for directory trees.
        export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
        export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

        # Docker CLI completions (added by Docker Desktop on first launch).
        if [[ -d "$HOME/.docker/completions" ]]; then
          fpath=($HOME/.docker/completions $fpath)
        fi
      ''
    ];
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$nodejs$python$golang$cmd_duration$line_break$character";
      # Character colors match reference; segments (nodejs/python/golang)
      # kept from the pre-migration config since they're actively useful here.
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      git_status.style = "bold red";
      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
        style = "yellow";
      };
      python = {
        symbol = " ";
        format = "[$symbol$pyenv_prefix($version )(\\($virtualenv\\) )]($style)";
        style = "yellow";
      };
      nodejs = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
        style = "green";
      };
      golang = {
        symbol = " ";
        format = "[$symbol($version )]($style)";
        style = "cyan";
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Note: programs.git is deliberately NOT enabled here. It would make
  # ~/.gitconfig a Nix-store-managed file, which breaks bootstrap.sh's
  # `git config --global user.name/user.email` identity prompt (can't write
  # to an immutable symlink). configs/gitconfig + the include.path wiring
  # stay exactly as bootstrap.sh already sets them up, until that's revisited.

  # Edit-in-place: the real files stay in this repo, ~/.config just points at them.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".tool-versions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.tool-versions";

  # CheatSheets symlink setup: this repo's docs/cheatsheets/ is the source of
  # truth; a-utils/cheatsheets just points at it.
  home.file."Documents/workspace/my-matrix/a-utils/cheatsheets".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/docs/cheatsheets";

  # LinearMouse writes back to its config file through the GUI's own
  # preferences UI (no export step) — mkOutOfStoreSymlink keeps the real
  # file in this repo instead of the read-only Nix store, and the
  # activation script below preserves any pre-existing real file the same
  # way bootstrap.sh's backup-before-symlink logic did.
  home.file.".config/linearmouse/linearmouse.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/linearmouse/linearmouse.json";

  home.activation.backupLinearMouseConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    TARGET="$HOME/.config/linearmouse/linearmouse.json"
    if [[ -f "$TARGET" && ! -L "$TARGET" ]]; then
      BACKUP="$TARGET.backup.$(date +%Y%m%d-%H%M%S)"
      $DRY_RUN_CMD mv "$TARGET" "$BACKUP"
    fi
  '';
}
