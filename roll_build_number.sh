#!/bin/bash
set -e

# Find and increment the version number.
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml

# Extract the new version info
version=$(grep '^version: ' pubspec.yaml | sed 's/version: //')
v_num=$(echo "$version" | cut -d'+' -f1)
echo "Rolling version to $version"

# Update doc/about.md
perl -i -pe "s/^title: About Spacetime.*/title: About Spacetime (v$version)/" \
     doc/about.md
perl -i -pe "s/^# About Spacetime.*/# About Spacetime (v$version)/" \
     doc/about.md

# Update README.md, GEMINI.md and plan.md
perl -i -pe "s/^# Spacetime Drawing Tool.*/# Spacetime Drawing Tool (v$version)/" \
     README.md
perl -i -pe "s/^Build Version.*/Build Version v$version/" \
     GEMINI.md
perl -i -pe "s/^# Spacetime Project Plan.*/# Spacetime Project Plan (v$version)/" \
     plan.md

# Update lib/widget.dart
perl -i -pe "s/About Spacetime v[^\"]+/About Spacetime v$version/" \
     lib/widget.dart

# Update web/version.json
cat <<EOF > web/version.json
{
  "version": "$version"
}
EOF

make docs web/favicon.ico

echo "GREEN: Version is now $version"
