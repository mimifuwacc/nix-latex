# nix-latex-sci

uplatex + dvipdfmx ベースの、日本語・理工系向け LaTeX ツールチェインを提供する Nix flake です。
latexmk の設定 (`.latexmkrc`) はグローバルに置かず、プロジェクトごとの flake から利用します。

> [!NOTE]
> 同梱の `.latexmkrc` はフォント探索パス (`OSFONTDIR`) を macOS 前提にしています。
> Linux でもビルドは通りますが、システムフォントは探索されません。

## クイックスタート

```sh
mkdir mydoc && cd mydoc
nix flake init -t github:mimifuwacc/nix-latex-sci   # テンプレートを展開
nix develop                                         # 開発シェルに入る
latexmk main.tex                                    # .latexmkrc に従って uplatex → dvipdfmx
```

direnv / VSCode と組み合わせるならバリアントを指定します。

```sh
nix flake init -t github:mimifuwacc/nix-latex-sci#vscode
direnv allow
```

| バリアント | 中身 |
| --- | --- |
| `default` | `flake.nix` / `.latexmkrc` / `main.tex` / `.gitignore` |
| `direnv` | 上記 + `.envrc` |
| `vscode` | 上記 + `.envrc` / `.vscode/settings.json`（LaTeX Workshop 設定） |

`nix flake init -t` は中身を cwd にコピーするだけで、以降リポジトリ側の更新には追従しません（ツールチェインの更新は `nix flake update`）。ディレクトリごと作るなら `nix flake new -t github:mimifuwacc/nix-latex-sci#vscode mydoc`。

## 既存プロジェクトに組み込む

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-latex-sci.url = "github:mimifuwacc/nix-latex-sci";
  };
  outputs = { self, nixpkgs, flake-utils, nix-latex-sci }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default = nix-latex-sci.devShells.${system}.default;
    });
}
```

`.latexmkrc` はリポジトリ直下に置きます。プロジェクト固有のツールを足したいときは `inputsFrom` で devShell を取り込みます。

```nix
devShells.default = pkgs.mkShell {
  inputsFrom = [ nix-latex-sci.devShells.${system}.default ];
  packages = [ pkgs.pandoc pkgs.imagemagick ];
};
```

## 収録パッケージ

`texliveSmall` に以下を `withPackages` で追加しています。下位コレクションや beamer・jvlisting 等は推移的に入ります。

| 指定 | 主な内容 |
| --- | --- |
| `collection-langjapanese` | uplatex/platex, jsclasses, 原ノ味フォント |
| `collection-latexextra` | beamer, tcolorbox, latexrecommended, pictures |
| `collection-mathscience` | amsmath 系, siunitx, bussproofs, 理工フォント |
| `latexmk` / `latexindent` | ビルド・整形ツール |

補助ツール: `ghostscript`

## ライセンス

[MIT](./LICENSE)
