{ config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    package = pkgs.fish;
    
    # Fish shell aliases
    shellAliases = {
      cls = "clear";
      g = "git";
      n = "nvim";
      m = "micro";
      ll = "lsd -la";
      la = "lsd -la";
      l = "lsd -l";
      lt = "lsd --tree";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "grep --color=auto";
      
      # NixOS specific
      rebuild = "sudo nixos-rebuild switch --flake .#meowrch";
      rebuild-boot = "sudo nixos-rebuild boot --flake .#meowrch";
      update = "nix flake update";
      clean = "sudo nix-collect-garbage -d";
      search = "nix search nixpkgs";
      
      # System monitoring
      htop = "btop";
      top = "btop";
      
      # File operations
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";
    };
    
    # Fish shell abbreviations
    shellAbbrs = {
      gst = "git status";
      gco = "git checkout";
      gaa = "git add --all";
      gcm = "git commit -m";
      gp = "git push";
      gl = "git pull";
      glog = "git log --oneline --graph";
      
      # Docker shortcuts
      dps = "docker ps";
      dpa = "docker ps -a";
      di = "docker images";
      
      # System shortcuts
      sctl = "systemctl";
      jctl = "journalctl";
    };
    
    # Fish functions
    functions = {
      # Custom wget function with XDG compliance
      wget = {
        body = ''
          command wget --hsts-file="$XDG_DATA_HOME/wget-hsts" $argv
        '';
      };
      
      # Custom nvidia-settings function with XDG compliance
      nvidia-settings = {
        body = ''
          mkdir -p $XDG_CONFIG_HOME/nvidia/
          command nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings" $argv
        '';
      };
      
      # Fish greeting with Pokemon
      fish_greeting = {
        body = ''
          if command -q pokemon-colorscripts
            pokemon-colorscripts --no-title -s -r 1,3,6
          else
            echo "🐱 Welcome to Meowrch! ≽ܫ≼"
          end
        '';
      };
      
      # Enhanced ls function
      ls = {
        body = ''
          if command -q lsd
            command lsd $argv
          else
            command ls --color=auto $argv
          end
        '';
      };
      
      # Cat with syntax highlighting
      cat = {
        body = ''
          if command -q bat
            command bat $argv
          else
            command cat $argv
          end
        '';
      };
      
      # Make directory and cd into it
      mkcd = {
        argumentNames = "dir";
        body = ''
          mkdir -p $dir && cd $dir
        '';
      };
      
      # Extract archives
      extract = {
        argumentNames = "file";
        body = ''
          if test -f $file
            switch $file
              case "*.tar.bz2"
                tar xjf $file
              case "*.tar.gz"
                tar xzf $file
              case "*.bz2"
                bunzip2 $file
              case "*.rar"
                unrar x $file
              case "*.gz"
                gunzip $file
              case "*.tar"
                tar xf $file
              case "*.tbz2"
                tar xjf $file
              case "*.tgz"
                tar xzf $file
              case "*.zip"
                unzip $file
              case "*.Z"
                uncompress $file
              case "*.7z"
                7z x $file
              case "*"
                echo "'$file' cannot be extracted via extract()"
            end
          else
            echo "'$file' is not a valid file"
          end
        '';
      };
      
      # Git clone and cd
      gclone = {
        argumentNames = "repo";
        body = ''
          git clone $repo
          set repo_name (basename $repo .git)
          cd $repo_name
        '';
      };
      
      # Find and kill process
      killp = {
        argumentNames = "name";
        body = ''
          set pids (ps aux | grep $name | grep -v grep | awk '{print $2}')
          if test -n "$pids"
            echo "Killing processes: $pids"
            echo $pids | xargs kill
          else
            echo "No processes found matching '$name'"
          end
        '';
      };
      
      # Quick edit config files
      config = {
        argumentNames = "file";
        body = ''
          switch $file
            case "fish"
              $EDITOR ~/.config/fish/config.fish
            case "hypr" or "hyprland"
              $EDITOR ~/.config/hypr/hyprland.conf
            case "waybar"
              $EDITOR ~/.config/waybar/config.jsonc
            case "kitty"
              $EDITOR ~/.config/kitty/kitty.conf
            case "rofi"
              $EDITOR ~/.config/rofi/config.rasi
            case "starship"
              $EDITOR ~/.config/starship.toml
            case "*"
              echo "Unknown config file: $file"
              echo "Available: fish, hypr, waybar, kitty, rofi, starship"
          end
        '';
      };
      
      # System information
      sysinfo = {
        body = ''
          echo "System Information:"
          echo "=================="
          
          if command -q fastfetch
            fastfetch
          else if command -q neofetch
            neofetch
          else
            echo "OS: "(uname -o)
            echo "Kernel: "(uname -r)
            echo "Architecture: "(uname -m)
            echo "Uptime: "(uptime -p)
            echo "Memory: "(free -h | awk '/^Mem:/ {print $3 "/" $2}')
          end
        '';
      };
      
      # Weather information
      weather = {
        argumentNames = "city";
        body = ''
          if test -n "$city"
            curl -s "wttr.in/$city?format=3"
          else
            curl -s "wttr.in/?format=3"
          end
        '';
      };
      
      # Backup function
      backup = {
        argumentNames = "source" "destination";
        body = ''
          if test -z "$source" -o -z "$destination"
            echo "Usage: backup <source> <destination>"
            return 1
          end
          
          set timestamp (date +"%Y%m%d_%H%M%S")
          set backup_name (basename $source)_$timestamp
          
          if test -d "$source"
            tar -czf "$destination/$backup_name.tar.gz" -C (dirname $source) (basename $source)
          else
            cp "$source" "$destination/$backup_name"
          end
          
          echo "Backup created: $destination/$backup_name"
        '';
      };
    };
    
    # Fish plugins and completions
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
          sha256 = "sha256-+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "50eba266b0746681fad7bc6b252f9b29c0e1b5b7";
          sha256 = "sha256-Zqcm6jhSrf5xbzzguw5pGR2GGApcfNzU6c5ofPbEA2g=";
        };
      }
    ];
    
    # Fish shell init
    interactiveShellInit = ''
      # Set custom variables
      set -g fish_greeting
      
      # Enable vi mode
      fish_vi_key_bindings
      
      # Set environment variables
      set -gx EDITOR micro
      set -gx VISUAL micro
      set -gx BROWSER firefox
      set -gx TERMINAL kitty
      
      # XDG directories
      set -gx XDG_DATA_HOME $HOME/.local/share
      set -gx XDG_CONFIG_HOME $HOME/.config
      set -gx XDG_STATE_HOME $HOME/.local/state
      set -gx XDG_CACHE_HOME $HOME/.cache
      
      # Application specific settings
      set -gx MICRO_TRUECOLOR 1
      set -gx GTK2_RC_FILES $XDG_CONFIG_HOME/gtk-2.0/gtkrc
      set -gx XCURSOR_PATH /usr/share/icons:$XDG_DATA_HOME/icons
      set -gx CARGO_HOME $XDG_DATA_HOME/cargo
      set -gx CUDA_CACHE_PATH $XDG_CACHE_HOME/nv
      set -gx GNUPGHOME $XDG_DATA_HOME/gnupg
      set -gx REDISCLI_HISTFILE $XDG_DATA_HOME/redis/rediscli_history
      set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
      set -gx NODE_REPL_HISTORY $XDG_DATA_HOME/node_repl_history
      set -gx PYENV_ROOT $XDG_DATA_HOME/pyenv
      set -gx WAKATIME_HOME $XDG_CONFIG_HOME/wakatime
      
      # Wayland/Qt settings
      set -gx QT_QPA_PLATFORM wayland;xcb
      set -gx QT_QPA_PLATFORMTHEME qt6ct
      set -gx QT_AUTO_SCREEN_SCALE_FACTOR 1
      set -gx GDK_SCALE 1
      
      # Java settings
      set -gx _JAVA_AWT_WM_NONREPARENTING 1
      set -gx _JAVA_OPTIONS '-Dsun.java2d.opengl=true'
      
      # Add paths
      fish_add_path $HOME/bin
      fish_add_path $HOME/.local/bin
      fish_add_path $CARGO_HOME/bin
      fish_add_path $PYENV_ROOT/bin
      
      # Initialize starship if available
      if command -q starship
        starship init fish | source
      end
      
      # Initialize zoxide if available
      if command -q zoxide
        zoxide init fish | source
      end
      
      # Initialize pyenv if available
      if command -q pyenv
        pyenv init - | source
      end
      
      # Bind custom key bindings
      bind \co 'fish_commandline_prepend sudo'
      bind \cr 'history | fzf | read -l result; and commandline $result'
      
      # Custom completions
      complete -c extract -a "(__fish_complete_suffix .tar.bz2)"
      complete -c extract -a "(__fish_complete_suffix .tar.gz)"
      complete -c extract -a "(__fish_complete_suffix .zip)"
      complete -c extract -a "(__fish_complete_suffix .rar)"
      complete -c extract -a "(__fish_complete_suffix .7z)"
      
      # Set color scheme
      set fish_color_normal cdd6f4
      set fish_color_autosuggestion 585b70
      set fish_color_command 89b4fa
      set fish_color_error f38ba8
      set fish_color_param f5c2e7
      set fish_color_comment 6c7086
      set fish_color_quote a6e3a1
      set fish_color_redirection f5c2e7
      set fish_color_end fab387
      set fish_color_match --background=brblue
      set fish_color_selection white --bold --background=brblack
      set fish_color_search_match bryellow --background=brblack
      set fish_color_history_current --bold
      set fish_color_operator 00a6b2
      set fish_color_escape 00a6b2
      set fish_color_cwd green
      set fish_color_cwd_root red
      set fish_color_valid_path --underline
      set fish_color_cancel -r
      set fish_pager_color_completion normal
      set fish_pager_color_description B3A06D yellow
      set fish_pager_color_prefix white --bold --underline
      set fish_pager_color_progress brwhite --background=cyan
    '';
  };
}