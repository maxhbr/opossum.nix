{
  description = "An OpossumUI Flake";

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {

        packages.opossumUI = with pkgs;
          let
            pname = "opossum-ui";
            version = "OpossumUI-2021-09-23";
            name = "${pname}-${version}";
            src = fetchurl {
               url =
                 "https://github.com/opossum-tool/OpossumUI/releases/download/${version}/OpossumUI-0.1.0.AppImage";
               sha256 = "NRlRoMcwrp0eFB9fHpWFNXUwFXGaGE9u+8FOqLgo5ik=";
             };

            appimageContents = appimageTools.extractType2 { inherit name src; };

            xdg_dirs = builtins.concatStringsSep ":" [
              "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
              "${hicolor-icon-theme}/share/gsettings-schemas/${hicolor-icon-theme.name}"
              "${gtk3}/share/gsettings-schemas/${gtk3.name}"
            ];
          in appimageTools.wrapType2 rec {
            inherit name src;

            extraPkgs = pkgs:
              with pkgs; [
                wrapGAppsHook
                gtk3
                hicolor-icon-theme
                firefox
              ];

            profile = ''
              export LC_ALL=C.UTF-8
              export XDG_DATA_DIRS="${xdg_dirs}''${XDG_DATA_DIRS:+:"$XDG_DATA_DIRS"}"
              export PATH="$PATH:${pkgs.firefox}/bin/"
            '';

            extraInstallCommands = ''
              mv $out/bin/opossum-ui* $out/bin/${pname}
            '';
          };

        defaultPackage = self.packages."${system}".opossumUI;

        defaultApp = {
          type = "app";
          program = "${self.defaultPackage."${system}"}/bin/opossum-ui";
        };

      });
}
