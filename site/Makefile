HUGO_DIR = ./data
HUGO_ENV = production
HUGO_FLAGS = --gc --minify --environment $(HUGO_ENV)
PROGRESSIVE_SCRIPT = tools/progressivify.sh
PORTFOLIO_DIR = $(HUGO_DIR)/public/portfolio
CACHE_SCRIPT = tools/cache-optimize.sh

.PHONY: all
all: build-optimized

.PHONY: build
build:
	cd $(HUGO_DIR) && hugo $(HUGO_FLAGS)

.PHONY: build-optimized
build-optimized:
	$(CACHE_SCRIPT)

.PHONY: progressivify
progressivify:
	$(PROGRESSIVE_SCRIPT) $(PORTFOLIO_DIR)

.PHONY: serve
serve:
	cd $(HUGO_DIR) && hugo server --buildDrafts --buildFuture

.PHONY: clean
clean:
	rm -rf $(HUGO_DIR)/public
	rm -f cache-manifest.txt

.PHONY: cache-headers
cache-headers:
	@echo "📋 Recommended cache headers for your CDN/reverse proxy:"
	@echo "Static assets (1 year): *.css, *.js, *.jpg, *.png, *.svg, *.woff2, *.pdf"
	@echo "HTML files (1 hour): *.html"
	@echo "Root pages (5 minutes): /, /index.html"
