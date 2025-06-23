# =============================================================================
# Developer Makefile
# =============================================================================

.PHONY: all clean help view watch report assignment ieee_paper presentation

all clean help view watch report assignment ieee_paper presentation:
	@$(MAKE) -C src $@ DOC=$(DOC)
