HUGO_DIR = ./data
HUGO_ENV = production
HUGO_FLAGS = --gc --minify --environment $(HUGO_ENV)
PROGRESSIVE_SCRIPT = tools/progressivify.sh
PORTFOLIO_DIR = $(HUGO_DIR)/public/portfolio

.PHONY: all
all: build progressivify

.PHONY: build
build:
	cd $(HUGO_DIR) && hugo $(HUGO_FLAGS)

.PHONY: progressivify
progressivify:
	$(PROGRESSIVE_SCRIPT) $(PORTFOLIO_DIR)
