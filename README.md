# nix-latex

uplatex + dvipdfmx ベースの日本語対応 LaTeX ツールチェインを提供する Nix flake です。
**プロジェクトごとの flake から利用する**前提で、latexmk の設定 (`.latexmkrc`) は
グローバルに展開せず各プロジェクトのリポジトリが持ちます。

> [!NOTE]
> 同梱の `.latexmkrc` のフォント探索パス (`OSFONTDIR`) は macOS 前提です。
> Linux でもビルドは通りますが、システムフォントの探索は効きません。

## クイックスタート

```sh
mkdir mydoc && cd mydoc
nix flake init -t github:mimifuwacc/nix-latex   # テンプレートを展開
nix develop                                     # ツールチェインの入ったシェルに入る
latexmk main.tex                                # cwd の .latexmkrc を読んで uplatex -> dvipdfmx
```

direnv や VSCode と組み合わせるなら、変種を指定します。

```sh
nix flake init -t github:mimifuwacc/nix-latex#vscode
direnv allow                                    # ツールチェインをエディタに拾わせる
```

| テンプレート | 中身 |
| --- | --- |
| `default` | `flake.nix` / `.latexmkrc` / `main.tex` / `.gitignore` |
| `direnv` | 上記 + `.envrc` |
| `vscode` | 上記 + `.envrc` / `.vscode/settings.json`（LaTeX Workshop 設定） |

`direnv allow` しておくと、VSCode のターミナルや LaTeX Workshop がプロジェクトの
ツールチェインを自動で拾います。

変種はすべて `template/` 1つのディレクトリから生成しています。エディタを足したい
ときは、そのファイルを `template/` に置いて `flake.nix` の `variants` に1エントリ
追加してください。

`nix flake init -t` はテンプレートの中身を cwd にコピーするだけのコマンドです。
展開後のファイルはプロジェクトのものになり、nix-latex 側の更新には追従しません
（追従するのは `flake.nix` の input 経由で入るツールチェインだけで、更新は
`nix flake update`）。既存ファイルは上書きせずエラーになります。ディレクトリごと
作るなら `nix flake new -t github:mimifuwacc/nix-latex#vscode mydoc`。

## 既存プロジェクトに組み込む

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-latex.url = "github:mimifuwacc/nix-latex";
  };
  outputs = { self, nixpkgs, flake-utils, nix-latex }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default = nix-latex.devShells.${system}.default;
    });
}
```

`.latexmkrc` はリポジトリ直下に置きます（テンプレートのものをコピーするのが手軽です）。

プロジェクト固有のツールも一緒に使いたいときは、`inputsFrom` で devShell を
取り込みつつ `packages` に足します。

```nix
devShells.default = pkgs.mkShell {
  inputsFrom = [ nix-latex.devShells.${system}.default ];
  packages = [ pkgs.pandoc pkgs.imagemagick ];
};
```

## 収録パッケージ

`texliveSmall` をベースに以下を `withPackages` で追加した構成です。下位コレクション
(basic / latex / latexrecommended / fontsrecommended / pictures / langcjk) や
beamer・bxjscls・bussproofs・jvlisting 等は推移的に入るため明示しません。

| 指定 | 主な内容 |
| --- | --- |
| `collection-langjapanese` | uplatex/platex, jsclasses, 原ノ味フォント, langcjk |
| `collection-latexextra` | beamer, jvlisting, tcolorbox, latexrecommended, pictures |
| `collection-mathscience` | amsmath 系, siunitx, bussproofs, 理工フォント |
| `latexmk` / `latexindent` | ビルド・整形ツール（latexindent はデフォルト設定） |

補助ツール: `ghostscript`, `gnuplot`

## ライセンス

[MIT](./LICENSE)
