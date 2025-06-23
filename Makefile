# =============================================================================
# Developer Makefile for LaTeX
# =============================================================================

DOCS		:= report assignment ieee_paper presentation
DOC 		?= report
SRC_DIR 	:= src/examples
BUILD_DIR 	:= build
VIEWER 		:= xdg-open

LATEXMK 		= latexmk
LATEXMK_FLAGS 	= -pdf -interaction=nonstopmode

.PHONY: all clean help view watch $(DOCS) build_pdf

all:
	@# Loop to build all documents sequentially. The '$$' is needed to escape '$' for the shell.
	@for doc in $(DOCS); do $(MAKE) $$doc; done
	@echo "All documents compiled successfully."

$(DOCS):
	@$(MAKE) build_pdf DOC=$@


build_pdf:
	@echo "================== Building DEV: $(DOC).tex =================="
	@# Create a specific output directory for the document, e.g., build/report/
	@mkdir -p $(BUILD_DIR)/$(DOC)
	@# Conditional logic to select the correct bibliography tool for latexmk.
	@# This uses the universally compatible '-e' flag.
	@if [ "$(DOC)" = "ieee_paper" ]; then \
		echo "--> Using BibTeX for IEEE paper..."; \
		$(LATEXMK) $(LATEXMK_FLAGS) -output-directory=$(BUILD_DIR)/$(DOC) -e '$$bibtex=q/bibtex %O %S/' $(SRC_DIR)/$(DOC).tex; \
	else \
		echo "--> Using Biber for $(DOC)..."; \
		$(LATEXMK) $(LATEXMK_FLAGS) -output-directory=$(BUILD_DIR)/$(DOC) -e '$$bibtex=q/biber %O %S/' $(SRC_DIR)/$(DOC).tex; \
	fi
	@echo "================== Compilation Done: $(DOC) ================="
	@# Verify that the PDF was actually created in its specific directory
	@if [ -f "$(BUILD_DIR)/$(DOC)/$(DOC).pdf" ]; then \
		echo "📄 PDF available at: $(BUILD_DIR)/$(DOC)/$(DOC).pdf"; \
	else \
		echo "❌ Error: PDF not created. Check $(BUILD_DIR)/$(DOC)/$(DOC).log for errors."; \
		exit 1; \
	fi
	@echo " "

view: build_pdf
	@echo "Opening $(BUILD_DIR)/$(DOC)/$(DOC).pdf..."
	@$(VIEWER) $(BUILD_DIR)/$(DOC)/$(DOC).pdf >/dev/null 2>&1 &

watch:
	@echo "🔎 Watching $(DOC).tex and its dependencies... Press Ctrl+C to stop."
	@mkdir -p $(BUILD_DIR)/$(DOC)
	@# Apply the same compatibility fix to watch mode
	@if [ "$(DOC)" = "ieee_paper" ]; then \
		$(LATEXMK) $(LATEXMK_FLAGS) -output-directory=$(BUILD_DIR)/$(DOC) -pvc -e '$$bibtex=q/bibtex %O %S/' $(SRC_DIR)/$(DOC).tex; \
	else \
		$(LATEXMK) $(LATEXMK_FLAGS) -output-directory=$(BUILD_DIR)/$(DOC) -pvc -e '$$bibtex=q/biber %O %S/' $(SRC_DIR)/$(DOC).tex; \
	fi

clean:
	@echo "🧹 Cleaning up the entire build directory..."
	@rm -rf $(BUILD_DIR)
	@echo "Cleanup complete."

help:
	@echo "Developer Makefile for the Modular LaTeX Project"
	@echo ""
	@echo "Usage: make [target] [DOC=<document_name>]"
	@echo ""
	@echo "This Makefile builds documents from 'src/templates/' using content from 'src/content_dev/'."
	@echo "Supported documents are: $(DOCS)"
	@echo ""
	@echo "MAIN TARGETS:"
	@echo "  all          (default) Compiles all documents."
	@echo "  report       Compiles only report.tex."
	@echo "  assignment   Compiles only assignment.tex."
	@echo "  ieee_paper   Compiles only ieee_paper.tex (using BibTeX)."
	@echo "  presentation Compiles only presentation.tex."
	@echo ""
	@echo "UTILITY TARGETS:"
	@echo "  view         Compile and open a document (default: $(DOC))."
	@echo "               e.g., 'make view DOC=presentation'"
	@echo "  watch        Watch a document for changes and recompile automatically."
	@echo "               e.g., 'make watch DOC=ieee_paper'"
	@echo "  clean        Remove the entire build/ directory."
	@echo "  help         Display this help message."