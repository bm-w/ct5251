FILE := $(dir $(lastword $(MAKEFILE_LIST)))
DIR := $(FILE:/=)
SRC_DIR := $(DIR)/src
PUB_DIR := $(DIR)/public
MOD_DIR := $(DIR)/node_modules

JADE_BIN := $(MOD_DIR)/jade/bin/jade
STYLUS_BIN := $(MOD_DIR)/stylus/bin/stylus
COFFEE_BIN := $(MOD_DIR)/coffee-script/bin/coffee
UGLIFY_BIN := $(MOD_DIR)/uglify-js/bin/uglifyjs


# Phony targets

.PHONY: install build clean clean-install clean-build publish

install:
	cd $(DIR) && npm install

build: \
	$(PUB_DIR)/index.html \
	$(PUB_DIR)/style/index.html \
	$(PUB_DIR)/assets/ct5251.css \
	$(PUB_DIR)/assets/ct5251.js

publish: build
	$(eval COMMIT_ID := $(shell git rev-parse HEAD))
	git checkout gh-pages
	rsync -r $(PUB_DIR)/ .
	git add -u
	@(git diff-index --quiet HEAD && echo "There are no new changes; not publishing...") || (\
		echo "Committing from \`$(COMMIT_ID)\` and pushing to \`gh-pages\`..." && \
		git commit -m "Published from master-branch commit $(COMMIT_ID)." && \
		git push origin gh-pages)
	git checkout master


# Directory targets

$(MOD_DIR):
	$(error "Run `make|npm install` instead...")

$(PUB_DIR):
	mkdir -p $(PUB_DIR)

$(PUB_DIR)/assets: $(PUB_DIR)
	mkdir -p $(PUB_DIR)/assets


# File targets

$(PUB_DIR)/index.html: $(SRC_DIR)/index.jade $(MOD_DIR) $(PUB_DIR)
	$(JADE_BIN) < $(SRC_DIR)/index.jade > $(PUB_DIR)/index.html

$(PUB_DIR)/style/index.html: $(SRC_DIR)/style.jade $(MOD_DIR) $(PUB_DIR)
	mkdir -p $(PUB_DIR)/style
	$(JADE_BIN) < $(SRC_DIR)/style.jade > $(PUB_DIR)/style/index.html

$(PUB_DIR)/assets/ct5251.css: $(SRC_DIR)/assets/base.styl $(MOD_DIR) $(PUB_DIR)/assets
	$(STYLUS_BIN) < $(SRC_DIR)/assets/base.styl > $(PUB_DIR)/assets/ct5251.css

WEB_SCRIPTS := \
	$(SRC_DIR)/assets/controllers.coffee	

$(PUB_DIR)/assets/ct5251.js: $(WEB_SCRIPTS) $(MOD_DIR) $(PUB_DIR)/assets
	$(COFFEE_BIN) -cbj /dev/null -p $(WEB_SCRIPTS) \
		| $(UGLIFY_BIN) - -m toplevel=true -c > $(PUB_DIR)/assets/ct5251.js


# Cleanup

clean: clean-build clean-install

clean-install:
	rm -rf $(MOD_DIR)

clean-build:
	rm -rf $(PUB_DIR)
