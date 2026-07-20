{
  description = "LaTeX toolchain (uplatex/dvipdfmx based, Japanese-ready) for per-project flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
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
            latexindent # formatter (default settings)
          ]);

          # The toolchain: plain latexmk (it reads the per-project ./.latexmkrc by
          # itself; no global config is injected) plus supporting tools.
          tools = [
            texEnv
            pkgs.ghostscript
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
      # `nix flake init -t github:mimifuwacc/nix-latex-sci[#<variant>]` to scaffold a
      # project whose flake provides this toolchain and whose repo owns the
      # .latexmkrc.
      #
      # Every variant is served from the single ./template directory, so no file
      # is duplicated on disk. A variant opts into `extras`; everything a variant
      # does not opt into is filtered out, and everything unlisted in any
      # `extras` is common to all variants.
      #
      # To add an editor: drop its files into ./template and add one entry here.
      # List extras as top-level entries of ./template (a file like ".envrc", or
      # a whole directory like ".vscode") -- naming a file *inside* a directory
      # would leave the directory behind, empty, in the variants that skip it.
      templates =
        let
          inherit (nixpkgs) lib;
          src = ./template;

          variants = {
            default = {
              extras = [ ];
              description = "LaTeX project (uplatex/dvipdfmx) using nix-latex-sci";
            };
            direnv = {
              extras = [ ".envrc" ];
              description = "LaTeX project using nix-latex-sci, with direnv";
            };
            vscode = {
              extras = [ ".envrc" ".vscode" ];
              description = "LaTeX project using nix-latex-sci, with VSCode (LaTeX Workshop) + direnv";
            };
          };

          # Union of every optional path; a variant excludes the ones it skips.
          allExtras = lib.unique (lib.concatMap (v: v.extras) (lib.attrValues variants));
        in
        lib.mapAttrs
          (name: variant: {
            path = builtins.path {
              name = "nix-latex-sci-template-${name}";
              path = src;
              filter =
                let
                  excluded = map (f: "${toString src}/${f}")
                    (lib.subtractLists variant.extras allExtras);
                in
                path: _type: !(builtins.elem path excluded);
            };
            inherit (variant) description;
          })
          variants;
    };
}
