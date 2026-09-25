{ defaultPackage }:
{ config, lib, ... }:
let
  cfg = config.programs.t3codeNightly;
  desktopId = "com.t3tools.T3Code.desktop";
in
{
  options.programs.t3codeNightly = {
    enable = lib.mkEnableOption "T3 Code desktop nightly";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "T3 Code nightly package providing the desktop launcher.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # T3 writes a hidden URL-handler launcher here at startup, using its raw
    # Electron executable. A store-backed symlink preserves the visible launcher
    # and Nix runtime wrapper instead. The app tolerates the read-only file.
    xdg.dataFile."applications/${desktopId}".source =
      "${cfg.package}/share/applications/${desktopId}";
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/t3code" = [ desktopId ];
        "x-scheme-handler/t3code-dev" = [ desktopId ];
      };
    };
  };
}
