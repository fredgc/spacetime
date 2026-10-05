#!/bin/bash -i
#
# Run this one time:
# flutter pub add json_annotation dev:build_runner dev:json_serializable
# flutter pub get
# And this:
# dart run build_runner build --delete-conflicting-outputs
#
# Then run this to continuously update the json parser:
dart run build_runner watch --delete-conflicting-outputs
