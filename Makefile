SHELL := /bin/bash
PROJECT := $(notdir $(CURDIR))

DRIVE_ICON_SIZES := 256 128 64 32 16
DRIVE_ICONS := $(patsubst %,assets/icons/drive-icon-%.png,$(DRIVE_ICON_SIZES))
FIREBASE_FILES := lib/firebase_options.dart android/app/google-services.json firebase.json

ASSETS := docs web/favicon.ico web/favicon.png web/about.html web/privacy.html web/terms.html web/privacy_es.html web/terms_es.html $(DRIVE_ICONS) lib/transform.g.dart lib/tutorials.g.dart $(FIREBASE_FILES)

web: $(ASSETS)
	flutter build web

apk: $(ASSETS)
	flutter build apk

apk-release: $(ASSETS)
	flutter build apk --release

aab: $(ASSETS)
	@if [ -z "$$KEYSTORE_PW" ] && [ ! -f "$$HOME/.android/key.properties" ]; then \
		read -rsp "Upload keystore password: " pw; echo ""; \
		KEYSTORE_PW="$$pw" flutter build appbundle --release; \
	else \
		flutter build appbundle --release; \
	fi
	# The owner should be "CN=GC House, O=GC House, C=US".
	keytool -printcert \
		-jarfile build/app/outputs/bundle/release/app-release.aab \
		| grep -E "Owner:|SHA1:|SHA256:"
	cp build/app/outputs/bundle/release/app-release.aab \
		~/Downloads/$(PROJECT).aab

play-store-assets: icon.xcf
	mkdir -p play_store_images
	icon-generate icon.xcf play_store_images

# User documentation files built from doc/*.md to assets/*.html
USER_DOCS_MD := $(wildcard doc/*.md)
USER_DOCS_HTML := $(patsubst doc/%.md,assets/%.html,$(USER_DOCS_MD))

# Developer documentation files built from *.md to assets/dev/*.html
DEV_DOCS_MD := plan.md README.md GEMINI.md tutorial_plan.md
DEV_DOCS_HTML := $(patsubst %.md,assets/dev/%.html,$(DEV_DOCS_MD))

# Tutorial script files built to lib/tutorials.g.dart
TUTORIALS_MD := $(wildcard assets/tutorials/*.md)
DEV_TUTORIALS_MD := $(wildcard assets/dev/tutorials/*.md)

.PHONY: web apk apk-release aab play-store-assets docs stage test test-fast test-all test-stress release ASSETS audit

docs: $(USER_DOCS_HTML) $(DEV_DOCS_HTML) web/about.html web/privacy.html web/terms.html web/privacy_es.html web/terms_es.html

assets/%.html: doc/%.md
	@mkdir -p assets
	pandoc $< -s --mathml --css=css/doc_style.css -o $@

web/about.html: assets/about.html
	@mkdir -p web/css
	cp -f assets/css/doc_style.css web/css/doc_style.css 2>/dev/null || true
	sed 's/ (v{{ VERSION }})//g' $< > $@

web/%.html: assets/%.html
	@mkdir -p web/css
	cp -f assets/css/doc_style.css web/css/doc_style.css 2>/dev/null || true
	cp -f $< $@

assets/dev/%.html: %.md
	@mkdir -p assets/dev
	pandoc $< -f markdown-yaml_metadata_block -s --mathml --metadata pagetitle="$*" --css=../css/doc_style.css -o $@

web/favicon.png: assets/icons/icon.png
	convert $< -background transparent -colorspace RGB -filter Lanczos -resize 32x32 -colorspace sRGB -strip -define png:exclude-chunk=date,time $@

assets/icons/drive-icon-%.png: assets/icons/icon.png
	convert $< -background transparent -colorspace RGB -filter Lanczos -resize $*x$* -colorspace sRGB -strip -define png:exclude-chunk=date,time $@

web/favicon.ico: assets/icons/icon.png
	convert $< -define icon:auto-resize=64,48,32,16 -background transparent -strip -define png:exclude-chunk=date,time $@
	dart run flutter_launcher_icons

assets/icons/icon.png assets/icons/foreground.png assets/icons/background.png: icon.xcf
	icon-generate icon.xcf

ASSETS: $(ASSETS)

test:
	python3 scripts/test_changed.py

test-fast:
	flutter test --exclude-tags release_audit,stress

test-all:
	flutter test --exclude-tags release_audit

test-stress:
	flutter test --tags stress

audit: $(ASSETS)
	flutter test test/audit_test.dart

stage:  $(ASSETS)
	flutter build web --dart-define=DEBUG_ENABLED=true
	echo "PURPLE: Beginning push to staging."
	firebase_stage.pl

stage-release:  $(ASSETS) audit
	flutter build web
	echo "PURPLE: Beginning push to staging."
	firebase_stage.pl

release: $(ASSETS) audit
	make web
	firebase_release.pl

# 
lib/transform.g.dart: lib/transform.dart
	dart run build_runner build --delete-conflicting-outputs
	echo "Run json-builder.sh to do continuous build"

lib/tutorials.g.dart: $(TUTORIALS_MD) $(DEV_TUTORIALS_MD) generate_tutorials.py
	python3 generate_tutorials.py

$(FIREBASE_FILES):
	flutterfire configure -y
