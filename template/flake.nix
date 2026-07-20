{
  description = "A LaTeX document";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-latex-sci.url = "github:mimifuwacc/nix-latex-sci";
  };

  outputs = { self, nixpkgs, flake-utils, nix-latex-sci }:
    flake-utils.lib.eachDefaultSystem (system: {
      # `nix develop` -> shell with latexmk/uplatex/dvipdfmx/... on PATH.
      # latexmk picks up the .latexmkrc in this directory automatically.
      devShells.default = nix-latex-sci.devShells.${system}.default;

      # `nix run` -> build main.tex with latexmk in this directory.
      apps.default = nix-latex-sci.apps.${system}.default;
    });
}
