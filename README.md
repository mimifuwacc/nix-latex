# nix-latex

uplatex + dvipdfmx ベースの日本語対応 LaTeX ツールチェインを提供する Nix flake です。
**プロジェクトごとの flake から利用する**ことを前提にしています。latexmk の設定
(`.latexmkrc`) はグローバルに展開せず、各プロジェクトのリポジトリが持ちます。

> [!NOTE]
> 同梱の `.latexmkrc` のフォント探索パス (`OSFONTDIR`) は macOS 前提です。
> Linux でもビルド・コンパイルは可能ですが、システムフォントの探索は効きません。

## クイックスタート（新規プロジェクト）

```sh
mkdir mydoc && cd mydoc
nix flake init -t github:mimifuwacc/nix-latex   # flake.nix / .latexmkrc / main.tex / .gitignore を生成
nix develop                                     # ツールチェインの入ったシェルに入る
latexmk main.tex                                # cwd の .latexmkrc を読んで uplatex -> dvipdfmx
```

テンプレートが置く `.latexmkrc` はそのプロジェクトの一部です。latexmk は実行ディレクトリの
`.latexmkrc` を自動的に読むため、グローバルな設定注入は一切ありません。

## 既存プロジェクトに組み込む

プロジェクトの `flake.nix`:

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
エディタ統合（VSCode LaTeX Workshop など）は [direnv](https://direnv.net/) で
`use flake` し、ツールをプロジェクトのシェルから拾わせるのがおすすめです。

## アドホックに使う

```sh
nix develop github:mimifuwacc/nix-latex          # 一時的にツールチェインを使う
nix run github:mimifuwacc/nix-latex -- main.tex  # cwd の .latexmkrc で latexmk を実行
```

## 収録パッケージ

TeX Live は次の最小構成で `texlive.combine` しています。下位コレクション
(basic / latex / latexrecommended / fontsrecommended / pictures / langcjk) や
beamer・bxjscls・bussproofs・jvlisting 等は推移的に含まれるため明示しません。

| 指定 | 主な内容 |
| --- | --- |
| `collection-langjapanese` | uplatex/platex, jsclasses, 原ノ味フォント, langcjk |
| `collection-latexextra` | beamer, jvlisting, tcolorbox, latexrecommended, pictures |
| `collection-mathscience` | amsmath 系, siunitx, bussproofs, 理工フォント |
| `latexmk` | ビルドドライバ |

補助ツール: `ghostscript`, `gnuplot`

## ライセンス

[MIT](./LICENSE)
