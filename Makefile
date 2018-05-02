.DEFAULT_GOAL := help

.PHONY: install
## Install the required dependencies
install:
	@if ! command -v "bundle" >/dev/null 2>&1; then echo "Bundler gem is required. Run '[sudo] gem install bundler' to install it."; exit 1; fi
	bundle --path=.bundle --binstubs=.bin

.PHONY: build
## Build the site
build: install
	bundle exec fastlane build

.PHONY: clean
## Clean the build artifacts
clean: install
	bundle exec fastlane clean

.PHONY: deploy
## Deploy the site
deploy: install
	bundle exec fastlane deploy

.PHONY: serve
## Serve the server locally
serve: install
	bundle exec jekyll serve --watch --drafts

.PHONY: help
# taken from this gist https://gist.github.com/rcmachado/af3db315e31383502660
## Show this help message.
help:
	$(info Usage: make [target...])
	$(info Available targets)
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                    \
		nb = sub( /^## /, "", helpMsg );              \
		if(nb == 0) {                                 \
			helpMsg = $$0;                              \
			nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
		}                                             \
		if (nb)                                       \
			print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts $$'\t' |          \
	grep --color '^[^ ]*'
