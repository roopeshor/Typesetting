# Typesetting Works

Sort of backup & reference folder for my typesetting works done in LaTeX and typst.
Nowadays I'm transitioning to Typst, so wont use LaTeX that often

## Compiling (Typst)

Uses typst `0.15.1`

`typst compile file.typ`

## Compiling (LaTeX)

> To compile these, its recommended to install entire texlive packages (`texlive-full`)
### Compile to pdf

`lualatex -shell-escape file.tex`

### Clean up whole directory
`./cleanup.sh`

### Clean up tmp files
`latexmk -C`

