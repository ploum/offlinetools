#!/bin/bash
# https://dev.to/learnbyexample/customizing-pandoc-to-generate-beautiful-pdfs-from-markdown-3lbj
header=~/dev/offlinetools/manuscript_templates/header.tex

pandoc *.md \
    -f gfm \
    --toc \
    --standalone \
    --top-level-division=chapter \
    --include-in-header $header \
    -V linkcolor:blue \
    -V geometry:a4paper \
    -V geometry:margin=4cm \
    --pdf-engine=xelatex \
    -o total.pdf
#    -V mainfont="DejaVu Serif" \
#    -V monofont="DejaVu Sans Mono" \

