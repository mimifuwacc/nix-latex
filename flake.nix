{
  description = "LaTeX toolchain (uplatex/dvipdfmx based, Japanese-ready) for per-project flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # texliveSmall (scheme-small) as the base, plus a minimal set of
        # top-level collections. Each lower-level collection (basic, latex,
        # latexrecommended, fontsrecommended, pictures, langcjk) and packages
        # like beamer/bxjscls/bussproofs/jvlisting are pulled in transitively,
        # so they are intentionally not listed here.
        texEnv = pkgs.texliveSmall.withPackages (ps: with ps; [
          collection-langjapanese # uplatex/platex, jsclasses, Japanese fonts, langcjk
          collection-latexextra # beamer, jvlisting, tcolorbox, recommended, pictures, ...
          collection-mathscience # amsmath stack, siunitx, bussproofs, science fonts, ...
          latexmk # build driver
        ]);

        # The toolchain: plain latexmk (it reads the per-project ./.latexmkrc by
        # itself; no global config is injected) plus supporting tools.
        tools = [
          texEnv
          pkgs.ghostscript
          pkgs.gnuplot
        ];

        latex = pkgs.buildEnv {
          name = "latex-env";
          paths = tools;
        };
      in
      {
        packages = {
          default = latex;
          inherit latex texEnv;
        };

        devShells.default = pkgs.mkShell {
          packages = tools;
        };

        # `nix run` -> latexmk in the current directory (uses ./.latexmkrc)
        apps.default = {
          type = "app";
          program = "${texEnv}/bin/latexmk";
          meta.description = "Run latexmk from the current directory";
        };

        formatter = pkgs.nixpkgs-fmt;
      })
    // {
      # `nix flake init -t github:mimifuwacc/nix-latex` to scaffold a project
      # whose flake provides this toolchain and whose repo owns the .latexmkrc.
      templates.default = {
        path = ./template;
        description = "LaTeX project (uplatex/dvipdfmx) using nix-latex";
      };
    };
}
