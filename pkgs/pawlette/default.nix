{ lib
, python3
, fetchFromGitHub
, meowrch-themes
, glib
, makeWrapper
}:

python3.pkgs.buildPythonApplication rec {
  pname = "pawlette";
  version = "0.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "Meowrch";
    repo = "pawlette";
    rev = "f214a8a8b3da97d002ed3ac411c0701c88197cfc";
    hash = "sha256-xiv4fuWtrXiV+blWw2xLaBUhigDffcrnnDYq3o01V/s=";
  };

  postPatch = ''
    # Relax pydantic version requirement and fix systemd package name for NixOS
    substituteInPlace pyproject.toml \
      --replace 'pydantic>=2.12.0,<3.0.0' 'pydantic>=2.11.0,<3.0.0' \
      --replace '"systemd>=0.17.1"' '"systemd-python>=0.17.1"'
    
    # Fix AttributeError and ValueError in journal handler initialization
    substituteInPlace src/pawlette/common/setup_loguru.py \
      --replace "journal.JournaldLogHandler" "journal.JournalHandler" \
      --replace 'journal.JournalHandler("pawlette")' 'journal.JournalHandler(SYSLOG_IDENTIFIER="pawlette")'

    # HARD-PATCH: Use absolute Nix Store path for themes
    substituteInPlace src/pawlette/constants.py \
      --replace 'SYS_THEMES_FOLDER = Path(f"/usr/share/{APPLICATION_NAME}")' 'SYS_THEMES_FOLDER = Path("${meowrch-themes}/share/pawlette")'

    # Ensure system themes are always used and prioritized
    substituteInPlace src/pawlette/core/manager.py \
      --replace 'path = cnst.THEMES_FOLDER / theme_name' 'path = cnst.SYS_THEMES_FOLDER / theme_name' \
      --replace 'for p in [sys_path, path]:' 'for p in [cnst.SYS_THEMES_FOLDER / theme_name]:'

    substituteInPlace src/pawlette/core/selective_manager.py \
      --replace 'path = cnst.THEMES_FOLDER / theme_name' 'path = cnst.SYS_THEMES_FOLDER / theme_name' \
      --replace 'for p in [sys_path, path]:' 'for p in [cnst.SYS_THEMES_FOLDER / theme_name]:'

    # Force dark/light mode preference based on theme name
    substituteInPlace src/pawlette/core/system_theme_appliers.py \
      --replace 'self.gsettings_key, theme_name' 'self.gsettings_key, theme_name]; mode = "prefer-light" if "latte" in theme_name else "prefer-dark"; subprocess.run(["${glib}/bin/gsettings", "set", "org.gnome.desktop.interface", "color-scheme", mode], check=False) #' \
      --replace 'self._update_gtk_config(config, theme_name)' 'self._update_gtk_config(config, theme_name); mode = "gtk-application-prefer-dark-theme=0" if "latte" in theme_name else "gtk-application-prefer-dark-theme=1"; self._update_gtk_config(config, mode, key_only=True) if hasattr(self, "_update_gtk_config") else None'
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
    makeWrapper
  ];

  postInstall = ''
    wrapProgram $out/bin/pawlette \
      --prefix PATH : ${lib.makeBinPath [ glib ]}
  '';

  propagatedBuildInputs = with python3.pkgs; [
    loguru
    packaging
    pydantic
    requests
    systemd-python
    tqdm
  ];

  pythonImportsCheck = [ "pawlette" ];

  meta = with lib; {
    description = "Utility for changing themes in the meowrch";
    homepage = "https://github.com/Meowrch/pawlette";
    license = licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "pawlette";
  };
}
