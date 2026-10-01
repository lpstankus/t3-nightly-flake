{ appimageTools, fetchurl, lib }:
let
  version = "0.0.45-nightly.20261001.2525";
  pname = "t3code-desktop-nightly";
  src = fetchurl {
    url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
    sha256 = "sha256-hCxUOOCVOL6h17FLWd5Vph9z46ODw4Hz4ZI1Lgh6WhQ=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;
  extraInstallCommands = ''
    install -Dm444 ${contents}/usr/share/icons/hicolor/512x512/apps/t3code.png \
      "$out/share/icons/hicolor/512x512/apps/t3code-nightly.png"
    mkdir -p "$out/share/applications"
    # Match Electron's desktop ID so GNOME can associate the window and launcher.
    cat > "$out/share/applications/com.t3tools.T3Code.desktop" <<EOF
[Desktop Entry]
Name=T3 Code (Nightly)
Comment=T3 Code desktop build
Exec=$out/bin/t3code-desktop-nightly --no-sandbox %U
Terminal=false
NoDisplay=false
Type=Application
Icon=t3code-nightly
StartupWMClass=t3code
MimeType=x-scheme-handler/t3code;x-scheme-handler/t3code-dev;
Categories=Development;
EOF
  '';
  meta = {
    description = "T3 Code nightly desktop app";
    homepage = "https://t3.codes";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
