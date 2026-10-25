DRIVE_ICON_SIZES := 256 128 64 32 16
DRIVE_ICONS := $(patsubst %,assets/icons/drive-icon-%.png,$(DRIVE_ICON_SIZES))

ASSETS := docs web/favicon.ico web/favicon.png $(DRIVE_ICONS) web/version.json lib/transform.g.dart lib/tutorials.g.dart

build_all: $(ASSETS)
	flutter build web
	echo XXX flutter build apk

# User documentation files built from doc/*.md to assets/*.html
USER_DOCS_MD := $(wildcard doc/*.md)
USER_DOCS_HTML := $(patsubst doc/%.md,assets/%.html,$(USER_DOCS_MD))

# Developer documentation files built from *.md to assets/dev/*.html
DEV_DOCS_MD := plan.md README.md GEMINI.md tutorial_plan.md
DEV_DOCS_HTML := $(patsubst %.md,assets/dev/%.html,$(DEV_DOCS_MD))

# Tutorial script files built to lib/tutorials.g.dart
TUTORIALS_MD := $(wildcard assets/tutorials/*.md)
DEV_TUTORIALS_MD := $(wildcard assets/dev/tutorials/*.md)

.PHONY: docs stage build_all test release ASSETS

docs: $(USER_DOCS_HTML) $(DEV_DOCS_HTML)

assets/%.html: doc/%.md
	@mkdir -p assets
	pandoc $< -s --mathml --css=css/doc_style.css -o $@

assets/dev/%.html: %.md
	@mkdir -p assets/dev
	pandoc $< -f markdown-yaml_metadata_block -s --mathml --metadata pagetitle="$*" --css=../css/doc_style.css -o $@

web/favicon.png: assets/icons/icon.png
	convert $< -background transparent -colorspace RGB -filter Lanczos -resize 32x32 -colorspace sRGB $@

assets/icons/drive-icon-%.png: assets/icons/icon.png
	convert $< -background transparent -colorspace RGB -filter Lanczos -resize $*x$* -colorspace sRGB $@

web/favicon.ico: assets/icons/icon.png
	convert $< -define icon:auto-resize=64,48,32,16 -background transparent $@
	dart run flutter_launcher_icons

assets/icons/icon.png assets/icons/foreground.png assets/icons/background.png: icon.xcf
	icon-generate icon.xcf

ASSETS: $(ASSETS)

test:
	flutter test

stage:  $(ASSETS)
	# ./roll_build_number.sh
	flutter build web --dart-define=DEBUG_ENABLED=true
	echo "PURPLE: Beginning push to staging."
	firebase_stage.pl

stage-release:  $(ASSETS)
	# ./roll_build_number.sh
	flutter build web
	echo "PURPLE: Beginning push to staging."
	firebase_stage.pl

release: $(ASSETS)
	./roll_build_number.sh --release
	make build_all
	firebase deploy

# 
lib/transform.g.dart: lib/transform.dart
	dart run build_runner build --delete-conflicting-outputs
	echo "Run json-builder.sh to do continuous build"

lib/tutorials.g.dart: $(TUTORIALS_MD) $(DEV_TUTORIALS_MD) generate_tutorials.py
	python3 generate_tutorials.py

web/version.json: pubspec.yaml
	@version=$$(grep '^version: ' pubspec.yaml | sed 's/version: //'); \
	echo "{\"version\": \"$$version\"}" > web/version.json

lib/firebase_options.dart android/app/google-services.json firebase.json:
	flutterfire configure -y
