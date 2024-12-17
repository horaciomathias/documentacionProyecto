.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

_install_latex:
	brew update && brew upgrade
	brew install --cask basictex
	brew install textidote
_install_latex_dependencies:
	sudo tlmgr update --self
	sudo tlmgr install latexmk blindtext placeins biblatex biblatex-ieee multirow titlesec xpatch silence subfigure texdoc biber cleveref hyperref glossaries xindy csquotes float enumitem appendix pdfpages
install: _install_latex _install_latex_dependencies ## Installs LaTeX on your system

_build_bcf:
	cd src && pdflatex -file-line-error -interaction=nonstopmode -synctex=1 -output-format=dvi main.tex || true
_build_bbl:
	cd src && biber main -q
_build_glossary:
	cd src && makeglossaries main
_build_pdf:
	cd src && pdflatex -file-line-error -interaction=nonstopmode -synctex=1 -output-format=pdf main.tex || true

compile: _build_bcf _build_bbl _build_glossary _build_pdf ## Compile the LaTeX project

lint: ## Lint the LaTeX project
	cd src && textidote main.tex > lint_report.html || true
	open src/lint_report.html
