{ lib
, python3
, fetchFromGitHub
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

    # Patch system themes path for NixOS
    substituteInPlace src/pawlette/constants.py \
      --replace 'SYS_THEMES_FOLDER = Path(f"/usr/share/{APPLICATION_NAME}")' 'SYS_THEMES_FOLDER = Path("/run/current-system/sw/share/pawlette")'

    # Prioritize system themes in get_theme and get_all_themes
    substituteInPlace src/pawlette/core/manager.py \
      --replace 'for i in [cnst.SYS_THEMES_FOLDER, cnst.THEMES_FOLDER]:' 'for i in [cnst.SYS_THEMES_FOLDER, cnst.THEMES_FOLDER]:' \
      --replace 'for p in [sys_path, path]:' 'for p in [sys_path, path]:'

    # Ensure dark theme preference is set in system_theme_appliers.py
    substituteInPlace src/pawlette/core/system_theme_appliers.py \
      --replace "self._update_gtk_config(config, theme_name)" "self._update_gtk_config(config, theme_name); self._update_gtk_config(config, 'gtk-application-prefer-dark-theme=1', key_only=True)" \
      --replace 'self.gsettings_key, theme_name' 'self.gsettings_key, theme_name]; subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", "prefer-dark"]) #'
  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

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
