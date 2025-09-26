{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    
    settings = {
      # Main configuration
      format = ''
        $all$character
      '';
      
      right_format = ''
        $cmd_duration
      '';
      
      # Add newline before prompt
      add_newline = true;
      
      # Character configuration
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[](bold green)";
      };
      
      # Directory configuration
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "~";
        read_only_style = "197";
        read_only = "  ";
        format = "at [$path]($style)[$read_only]($read_only_style) ";
        style = "bold cyan";
      };
      
      # Git configuration
      git_branch = {
        symbol = " ";
        format = "on [$symbol$branch]($style) ";
        style = "bold purple";
        truncation_length = 4;
        truncation_symbol = "…";
        only_attached = false;
      };
      
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "cyan";
        conflicted = "🏳";
        up_to_date = " ";
        untracked = " ";
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
        stashed = " ";
        modified = " ";
        staged = "[++\${count}](green)";
        renamed = "襁 ";
        deleted = " ";
      };
      
      # Git commit configuration
      git_commit = {
        commit_hash_length = 4;
        tag_symbol = "🔖 ";
        format = "[\\($hash$tag\\)]($style) ";
        style = "green";
      };
      
      # Git state configuration
      git_state = {
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        style = "bright-black";
      };
      
      # Git metrics configuration
      git_metrics = {
        added_style = "bold blue";
        deleted_style = "bold red";
        only_nonzero_diffs = true;
        format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
        disabled = false;
      };
      
      # Command duration
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style)";
        style = "yellow bold";
        show_milliseconds = false;
        disabled = false;
      };
      
      # Hostname
      hostname = {
        ssh_only = false;
        ssh_symbol = " ";
        format = "[$ssh_symbol](bold blue) on [$hostname](bold red) ";
        trim_at = ".companyname.com";
        disabled = false;
      };
      
      # Username
      username = {
        style_user = "white bold";
        style_root = "black bold";
        format = "user: [$user]($style) ";
        disabled = false;
        show_always = true;
      };
      
      # Time
      time = {
        disabled = false;
        format = "🕙[$time]($style) ";
        time_format = "%T";
        utc_time_offset = "local";
        style = "bold yellow";
      };
      
      # Battery
      battery = {
        full_symbol = " ";
        charging_symbol = " ";
        discharging_symbol = " ";
        unknown_symbol = " ";
        empty_symbol = " ";
        format = "[$symbol$percentage]($style) ";
        
        display = [
          {
            threshold = 10;
            style = "bold red";
          }
          {
            threshold = 30;
            style = "bold yellow";
          }
        ];
      };
      
      # Memory usage
      memory_usage = {
        disabled = false;
        threshold = -1;
        symbol = " ";
        style = "bold dimmed green";
        format = "via $symbol[$ram( | $swap)]($style) ";
      };
      
      # Load
      load = {
        disabled = false;
        format = "load [$loadavg1( $loadavg5( $loadavg15))]($style) ";
        style = "bold blue";
      };
      
      # Package version
      package = {
        format = "is [$symbol$version]($style) ";
        symbol = "📦 ";
        style = "208";
        display_private = false;
        disabled = false;
      };
      
      # Programming languages
      
      # Python
      python = {
        symbol = " ";
        python_binary = ["./venv/bin/python" "python" "python3" "python2"];
        detect_extensions = ["py"];
        version_format = "v\${raw}";
        format = "via [\${symbol}\${pyenv_prefix}(\${version} )(\\($virtualenv\\) )]($style)";
        style = "yellow bold";
        pyenv_version_name = false;
        pyenv_prefix = "pyenv ";
        disabled = false;
      };
      
      # Node.js
      nodejs = {
        format = "via [ $version]($style) ";
        version_format = "v\${raw}";
        symbol = " ";
        style = "bold green";
        disabled = false;
        not_capable_style = "bold red";
        detect_extensions = ["js" "mjs" "cjs" "ts" "mts" "cts"];
        detect_files = ["package.json" ".node-version"];
        detect_folders = ["node_modules"];
      };
      
      # Rust
      rust = {
        format = "via [ $version]($style) ";
        version_format = "v\${raw}";
        symbol = " ";
        style = "bold red";
        disabled = false;
        detect_extensions = ["rs"];
        detect_files = ["Cargo.toml"];
      };
      
      # Go
      golang = {
        format = "via [ $version]($style) ";
        version_format = "v\${raw}";
        symbol = " ";
        style = "bold cyan";
        disabled = false;
        detect_extensions = ["go"];
        detect_files = [
          "go.mod"
          "go.sum"
          "go.work"
          "glide.yaml"
          "Gopkg.yml"
          "Gopkg.lock"
          ".go-version"
        ];
        detect_folders = ["Godeps"];
      };
      
      # Java
      java = {
        disabled = false;
        format = "via [☕ $version]($style) ";
        version_format = "v\${raw}";
        style = "red dimmed";
        symbol = "☕ ";
        detect_extensions = ["java" "class" "jar" "gradle" "clj" "cljc"];
        detect_files = [
          "pom.xml"
          "build.gradle.kts"
          "build.sbt"
          ".java-version"
          "deps.edn"
          "project.clj"
          "build.boot"
        ];
      };
      
      # C/C++
      c = {
        format = "via [$symbol($version(-$name) )]($style)";
        version_format = "v\${raw}";
        style = "149 bold";
        symbol = " ";
        disabled = false;
        detect_extensions = ["c" "h"];
        detect_files = [];
        detect_folders = [];
        commands = [
          ["cc" "--version"]
          ["gcc" "--version"]
          ["clang" "--version"]
        ];
      };
      
      # Docker
      docker_context = {
        format = "via [ $context]($style) ";
        style = "blue bold";
        symbol = " ";
        only_with_files = true;
        disabled = false;
        detect_extensions = [];
        detect_files = [
          "docker-compose.yml"
          "docker-compose.yaml"
          "Dockerfile"
        ];
        detect_folders = [];
      };
      
      # Kubernetes
      kubernetes = {
        format = "on [ $context( ($namespace))]($style) ";
        style = "cyan bold";
        symbol = "☸ ";
        disabled = true;
        detect_extensions = [];
        detect_files = [];
        detect_folders = [];
        contexts = [];
        user_aliases = {};
      };
      
      # Terraform
      terraform = {
        format = "via [ terraform $version$workspace]($style) ";
        version_format = "v\${raw}";
        symbol = "💠";
        style = "bold 105";
        disabled = false;
        detect_extensions = ["tf" "tfplan" "tfstate"];
        detect_files = [];
        detect_folders = [".terraform"];
      };
      
      # AWS
      aws = {
        format = "on [ ($profile )(\\($region\\) )(\\[$duration\\] )]($style)";
        symbol = "☁️  ";
        style = "bold blue";
        disabled = false;
        expiration_symbol = "X";
        force_display = false;
      };
      
      # Azure
      azure = {
        disabled = false;
        format = "on [ ($subscription)]($style) ";
        symbol = "ﴃ ";
        style = "blue bold";
      };
      
      # Google Cloud
      gcloud = {
        format = "on [ ($account@$domain)(\\($region\\))]($style) ";
        symbol = "☁️  ";
        style = "bold blue";
        disabled = false;
      };
      
      # NixOS
      nix_shell = {
        disabled = false;
        impure_msg = "[impure shell](bold red)";
        pure_msg = "[pure shell](bold green)";
        unknown_msg = "[unknown shell](bold yellow)";
        format = "via [☃️  $state( \\($name\\))]($style) ";
        style = "bold blue";
      };
      
      # Environment variables
      env_var = {
        variable = "SHELL";
        default = "unknown shell";
        format = "with [$env_value]($style) ";
        symbol = "";
        style = "black bold dimmed";
        disabled = true;
      };
      
      # Custom commands
      custom = {
        # Show if we're in a NixOS system
        nixos = {
          command = "echo 'NixOS'";
          when = "test -f /etc/NIXOS";
          format = "on [$symbol($output )]($style)";
          symbol = " ";
          style = "bold blue";
          disabled = false;
        };
        
        # Show current Hyprland workspace if in Hyprland
        hyprland_workspace = {
          command = "hyprctl activeworkspace -j | jq -r '.id' 2>/dev/null || echo ''";
          when = "test -n \"$HYPRLAND_INSTANCE_SIGNATURE\"";
          format = "workspace [$symbol$output]($style) ";
          symbol = " ";
          style = "bold purple";
          disabled = false;
        };
      };
      
      # Status
      status = {
        style = "bg:blue";
        symbol = "🔴 ";
        success_symbol = "";
        not_executable_symbol = "🚫";
        not_found_symbol = "🔍";
        sigint_symbol = "🧱";
        signal_symbol = "⚡";
        format = "[$symbol$status]($style) ";
        map_symbol = false;
        disabled = false;
      };
      
      # Shell
      shell = {
        fish_indicator = " ";
        powershell_indicator = "_";
        unknown_indicator = "mystery shell";
        style = "cyan bold";
        disabled = false;
      };
      
      # SHLVL
      shlvl = {
        disabled = false;
        format = "$shlvl level(s) down";
        threshold = 3;
        style = "bold yellow";
        symbol = "↕️  ";
      };
      
      # Jobs
      jobs = {
        threshold = 1;
        symbol_threshold = 1;
        number_threshold = 2;
        format = "[$symbol$number]($style) ";
        symbol = "✦";
        style = "bold blue";
        disabled = false;
      };
      
      # Sudo
      sudo = {
        style = "bold red";
        symbol = "🧙 ";
        disabled = false;
      };
      
      # Singularity
      singularity = {
        format = "[$symbol\\[$env\\]]($style) ";
        symbol = "";
        style = "blue bold dimmed";
        disabled = false;
      };
      
      # VCSH
      vcsh = {
        symbol = "";
        style = "bold yellow";
        format = "vcsh [$symbol$repo]($style) ";
        disabled = false;
      };
      
      # Fill
      fill = {
        symbol = " ";
        style = "bold black";
        disabled = false;
      };
    };
  };
}