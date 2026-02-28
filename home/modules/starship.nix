{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    package = pkgs.starship;
    
    settings = {
      # Main configuration
      format = "$directory$git_branch$git_status$nix_shell$character";
      right_format = "$cmd_duration";
      
      # Add newline before prompt
      add_newline = true;
      
      # Character configuration
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
      
      # Directory configuration
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "~";
        read_only_style = "197";
        read_only = " 🔒";
        format = "[$path]($style)[$read_only]($read_only_style) ";
        style = "bold cyan";
      };
      
      # Git configuration
      git_branch = {
        symbol = " ";
        format = "on [$symbol$branch]($style) ";
        style = "bold purple";
      };
      
      git_status = {
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        style = "cyan";
        conflicted = "🏳";
        up_to_date = " ";
        untracked = " ";
        ahead = "⇡${"$"}{count}";
        diverged = "⇕⇡${"$"}{ahead_count}⇣${"$"}{behind_count}";
        behind = "⇣${"$"}{count}";
        stashed = " ";
        modified = " ";
        staged = "[++${"$"}{count}](green)";
        renamed = "襁 ";
        deleted = " ";
      };
      
      # Command duration
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style)";
        style = "yellow bold";
      };
      
      # Disable unnecessary modules for minimalist look
      username = { disabled = true; };
      hostname = { disabled = true; };
      time = { disabled = true; };
      battery = { disabled = true; };
      memory_usage = { disabled = true; };
      
      # Language modules (minimalist)
      python = { symbol = "🐍 "; format = "[$symbol$version]($style) "; style = "yellow bold"; };
      nodejs = { symbol = " "; format = "[$symbol$version]($style) "; style = "bold green"; };
      rust = { symbol = " "; format = "[$symbol$version]($style) "; style = "bold red"; };
      golang = { symbol = " "; format = "[$symbol$version]($style) "; style = "bold cyan"; };
      
      # NixOS
      nix_shell = {
        symbol = "❄️  ";
        format = "via [$symbol$state]($style) ";
        style = "bold blue";
      };
    };
  };
}
