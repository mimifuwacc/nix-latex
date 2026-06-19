#!/usr/bin/env perl

# Make macOS user/system fonts discoverable by dvipdfmx via kpathsea
$ENV{OSFONTDIR} = "$ENV{HOME}/Library/Fonts//:/Library/Fonts//:/System/Library/Fonts//";

# PDF generation mode: 3 = build DVI then convert with dvipdfmx
# (standard for Japanese LaTeX; mode 1 would run pdflatex directly)
$pdf_mode = 3;

# LaTeX engine: uplatex with shell-escape for advanced packages.
# -interaction=nonstopmode keeps the engine from stopping at errors,
# -synctex=1 emits SyncTeX data for editor synchronization.
$latex = 'uplatex --shell-escape -interaction=nonstopmode -synctex=1 %O %S';

# DVI to PDF conversion
$dvipdf = 'dvipdfmx %O -o %D %S';

# BibTeX / index tools for Japanese (upbibtex + mendex)
$bibtex = 'upbibtex';
$makeindex = 'mendex';

# Auto-detect file dependencies
$dependents_list = 1;

# Clean up these generated files (latexmk -c / -C)
@generated_exts = qw(aux bbl blg idx ilg ind log out toc synctex.gz fdb_latexmk fls);
