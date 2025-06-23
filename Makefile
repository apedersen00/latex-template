# =============================================================================
# User Makefile for LaTeX
# =============================================================================

TARGET      := main
BUILD_DIR   := build
SRC         := $(TARGET).tex
PDF         := $(BUILD_DIR)/$(TARGET).pdf

VIEWER := xdg-open

LATEXMK = latexmk -pdf -output-directory=$(BUILD_DIR) -interaction=nonstopmode

.PHONY: all view watch clean help

all:
	@echo "================== Invoking latexmk =================="
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) $(SRC)
	@echo "================== Compilation Done ================="
	@# Verify that the PDF was actually created
	@if [ -f "$(PDF)" ]; then \
		echo "PDF available at: $(PDF)"; \
	else \
		echo "Error: PDF not created. Check build/main.log for errors."; \
		exit 1; \
	fi
	@echo " "

view: all
	@echo "Opening $(PDF)..."
	@$(VIEWER) $(PDF) >/dev/null 2>&1 &

watch:
	@echo "Watching for file changes... Press Ctrl+C to stop."
	@mkdir -p $(BUILD_DIR)
	$(LATEXMK) -pvc $(SRC)

clean:
	@echo "Cleaning up generated files..."
	# latexmk's -C command cleans the root directory of aux files
	@latexmk -C $(SRC) > /dev/null 2>&1
	# Also remove the build directory itself
	@rm -rf $(BUILD_DIR)
	@echo "Cleanup complete."

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Targets:"
	@echo "  all      (default) Compile the LaTeX document correctly."
	@echo "  view     Compile the document and open the resulting PDF."
	@echo "  watch    Watch for changes and recompile automatically."
	@echo "  clean    Remove all generated files and the build directory."
	@echo "  help     Display this help message."
