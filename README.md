# nix-latex

uplatex + dvipdfmx ベースの日本語対応 LaTeX 環境を提供する flake です。
パッケージ構成・設定は私の dotfiles (`system/darwin/anemone`) を踏襲しています。

> [!NOTE]
> `config/latexmkrc` のフォント探索パス (`OSFONTDIR`) は macOS 前提です。
> Linux でもビルド・コンパイルは可能ですが、システムフォントの探索は効きません。

## 使い方

### dev shell に入る

```sh
nix develop
```

`latexmk` / `latexindent` は `config/` の設定を読み込むラッパーに差し替わっており、
`uplatex` `dvipdfmx` `upbibtex` `mendex` `gs` `gnuplot` などもそのまま使えます。

```sh
latexmk main.tex        # uplatex -> dvipdfmx で PDF を生成
latexindent -w main.tex # bundled latexindent.yaml で整形
```

### そのままビルドする

```sh
nix run github:mimifuwacc/nix-latex -- main.tex   # ラッパー版 latexmk を実行
```

### プロファイル / 他 flake から使う

```sh
nix profile install github:mimifuwacc/nix-latex   # latex-env をインストール
```

```nix
# 他の flake から
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
| `latexmk` / `latexindent` | ビルド・整形ツール |

補助ツール: `ghostscript`, `gnuplot`

## 中身

- `flake.nix` — TeX Live (`texlive.combine`) + 補助ツール、設定入りラッパー
- `config/latexmkrc` — latexmk 設定（`$pdf_mode = 3`: DVI 経由で dvipdfmx）
- `config/latexindent.yaml` — latexindent 設定

## 出力

| 出力 | 内容 |
| --- | --- |
| `packages.default` / `packages.latex` | ラッパー + TeX Live + ghostscript + gnuplot をまとめた環境 |
| `packages.texEnv` | `texlive.combine` 単体 |
| `devShells.default` | 上記をそろえた開発シェル |
| `apps.default` | ラッパー版 `latexmk` |

## ライセンス

[MIT](./LICENSE)
