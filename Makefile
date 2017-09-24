.PHONY: install
install:
	./setup.sh

.PHONY: build
build: install
	bundle exec jekyll build --drafts

.PHONY: serve
serve: install
	bundle exec fastlane serve
