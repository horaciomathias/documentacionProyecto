.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk "BEGIN {FS = \":.*?## \"}; {printf \"\033[36m%-30s\033[0m %s\n\", $$1, $$2}"

# Detectar sistema operativo
ifeq ($(OS),Windows_NT)
    CLEAN_CMD := del /Q
    LATEX_DEP_CMD := initexmf --update-fndb && mpm --install=latexmk,blindtext,placeins,biblatex,biblatex-ieee,multirow,titlesec,xpatch,silence,subfigure,texdoc,biber,cleveref,hyperref,glossaries,xindy,csquotes,float,enumitem,appendix,pdfpages
else
    CLEAN_CMD := rm -f
    LATEX_DEP_CMD := tlmgr update --self && tlmgr install latexmk blindtext placeins biblatex biblatex-ieee multirow titlesec xpatch silence subfigure texdoc biber cleveref hyperref glossaries xindy csquotes float enumitem appendix pdfpages
endif

# Instalación de dependencias de LaTeX
_install_latex_dependencies:
	@echo "Instalando paquetes de LaTeX..."
	@$(LATEX_DEP_CMD)
	@echo "Paquetes instalados correctamente."

install: _install_latex_dependencies ## Instala dependencias LaTeX según el sistema operativo

# Compilación del proyecto
_build_bcf:
	cd src && pdflatex -file-line-error -interaction=nonstopmode -synctex=1 main.tex || exit 0

_build_bbl:
	cd src && biber main -q

_build_glossary:
	cd src && makeglossaries main

_build_pdf:
	cd src && pdflatex -file-line-error -interaction=nonstopmode -synctex=1 main.tex || exit 0

compile: _build_bcf _build_bbl _build_glossary _build_pdf ## Compila el proyecto LaTeX en PDF

# Linting del proyecto con textidote
lint:
	@echo "Generando reporte de lint con textidote..."
	textidote src/main.tex > src/lint_report.html || exit 0
	@echo "Reporte de lint generado: src/lint_report.html"

clean: ## Limpia los archivos temporales generados por LaTeX
	cd src && $(CLEAN_CMD) *.aux *.bbl *.bcf *.blg *.dvi *.glg *.glo *.gls *.ilg *.log *.out *.synctex.gz *.toc *.xml || exit 0
	@echo "Archivos temporales eliminados."
