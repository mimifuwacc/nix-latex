# nix-latex

uplatex + dvipdfmx ベースの日本語対応 LaTeX 環境を提供する Nix flake です。

> [!NOTE]
> `config/latexmkrc` のフォント探索パス (`OSFONTDIR`) は macOS 前提です。
> Linux でもビルド・コンパイルは可能ですが、システムフォントの探索は効きません。

## 使い方

### dev shell に入る

```sh
nix develop
```

`latexmk` は `config/latexmkrc` を読み込むラッパーに差し替わっており、
`uplatex` `dvipdfmx` `upbibtex` `mendex` `gs` `gnuplot` などもそのまま使えます。

```sh
latexmk main.tex   # uplatex -> dvipdfmx で PDF を生成
```

### そのままビルドする

```sh
nix run github:mimifuwacc/nix-latex -- main.tex
```

### インストール / 他 flake から使う

```sh
nix profile install github:mimifuwacc/nix-latex
```

```nix
{
  inputs.nix-latex.url = "github:mimifuwacc/nix-latex";
  # 例: home.packages = [ nix-latex.packages.${system}.default ];
}
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
