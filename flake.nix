{
  description = "LaTeX environment (uplatex/dvipdfmx based, Japanese-ready)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Minimal set of top-level collections; each lower-level collection
        # (basic, latex, latexrecommended, fontsrecommended, pictures, langcjk)
        # and packages like beamer/bxjscls/bussproofs/jvlisting are pulled in
        # transitively, so they are intentionally not listed here.
        texEnv = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            collection-langjapanese # uplatex/platex, jsclasses, Japanese fonts, langcjk
            collection-latexextra # beamer, jvlisting, tcolorbox, recommended, pictures, ...
            collection-mathscience # amsmath stack, siunitx, bussproofs, science fonts, ...
            latexmk; # build driver
        };

        # Bundled config files
        latexmkrc = ./config/latexmkrc;

        # Wrap latexmk so it always loads the bundled .latexmkrc
        latexmk = pkgs.writeShellScriptBin "latexmk" ''
          exec ${texEnv}/bin/latexmk -r ${latexmkrc} "$@"
        '';

        # Supporting tools used by the LaTeX toolchain
        extraTools = [
          pkgs.ghostscript
          pkgs.gnuplot
        ];

        # Single package that bundles everything. The latexmk wrapper shadows
        # the one shipped inside texEnv via a higher priority.
        latex = pkgs.buildEnv {
          name = "latex-env";
          paths = [
            (pkgs.lib.hiPrio latexmk)
            texEnv
          ] ++ extraTools;
        };
      in
      {
        packages = {
          default = latex;
          inherit latex texEnv;
        };

        devShells.default = pkgs.mkShell {
          packages = [ latexmk texEnv ] ++ extraTools;
        };

        # `nix run` -> build a document with latexmk
        apps.default = {
          type = "app";
          program = "${latexmk}/bin/latexmk";
          meta.description = "Run latexmk with the bundled .latexmkrc";
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
