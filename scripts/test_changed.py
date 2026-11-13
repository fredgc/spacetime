#!/usr/bin/env python3
"""Run targeted Flutter tests based on recently changed files."""

import os
import subprocess
import sys

# Mapping from source path patterns to test files
MAPPING = {
    "lib/name.dart": ["test/name_test.dart"],
    "lib/navigation.dart": ["test/nav_test.dart"],
    "lib/help.dart": ["test/nav_test.dart"],
    "lib/my_app.dart": ["test/nav_test.dart", "test/layout_test.dart"],
    "lib/widgets/": ["test/layout_test.dart", "test/nav_test.dart"],
    "lib/upload.dart": ["test/upload_test.dart"],
    "lib/scene": ["test/json_test.dart", "test/simple_test.dart"],
    "lib/transform.dart": [
        "test/transform_test.dart",
        "test/relativity_test.dart",
    ],
    "lib/drawable": [
        "test/simple_test.dart",
        "test/relativity_test.dart",
    ],
    "lib/axis.dart": ["test/axis_test.dart"],
    "lib/sprites.dart": ["test/sprites_test.dart"],
    "lib/splitter.dart": ["test/splitter_test.dart"],
    "lib/color.dart": ["test/color_test.dart"],
    "lib/edit.dart": ["test/edit_test.dart"],
    "lib/file_manager.dart": ["test/local_file_test.dart"],
    "lib/file_holder.dart": ["test/local_file_test.dart"],
    "lib/local_file.dart": ["test/local_file_test.dart"],
    "lib/recent_file.dart": ["test/local_file_test.dart"],
    "lib/drive": ["test/drive_cache_test.dart"],
    "lib/mouse.dart": ["test/mouse_test.dart"],
    "lib/slider.dart": ["test/slider_test.dart"],
    "lib/settings.dart": ["test/settings_test.dart"],
    "lib/worker.dart": ["test/worker_test.dart"],
    "lib/script": ["test/script_test.dart", "test/tutorial_test.dart"],
    "lib/tutorial_widget.dart": [
        "test/script_test.dart",
        "test/tutorial_test.dart",
    ],
    "lib/animate.dart": ["test/async_test.dart", "test/animator_test.dart"],
    "lib/printer.dart": ["test/printer_test.dart"],
    "lib/keyboard_detector.dart": ["test/keyboard_detector_test.dart"],
    "lib/l10n": ["test/i18n_test.dart"],
    "doc/": ["test/i18n_test.dart"],
    "assets/tutorials": [
        "test/tutorial_test.dart",
        "test/script_test.dart",
        "test/i18n_test.dart",
    ],
    "lib/tutorials.g.dart": [
        "test/tutorial_test.dart",
        "test/script_test.dart",
    ],
}


def get_changed_files():
    """Retrieve list of modified/untracked files from git."""
    changed = set()
    # 1. Unstaged and staged modifications + untracked files
    try:
        status_proc = subprocess.run(
            ["git", "status", "--porcelain"],
            capture_output=True,
            text=True,
            check=True,
        )
        for line in status_proc.stdout.splitlines():
            line = line.strip()
            if not line:
                continue
            # format: 'XY path' or 'XY path -> new_path'
            parts = line.split(maxsplit=1)
            if len(parts) >= 2:
                path = parts[1]
                if " -> " in path:
                    path = path.split(" -> ")[1]
                changed.add(path)
    except subprocess.CalledProcessError:
        pass

    # 2. If working tree is clean, check last commit diff
    if not changed:
        try:
            diff_proc = subprocess.run(
                ["git", "diff", "--name-only", "HEAD~1", "HEAD"],
                capture_output=True,
                text=True,
                check=True,
            )
            for line in diff_proc.stdout.splitlines():
                line = line.strip()
                if line:
                    changed.add(line)
        except subprocess.CalledProcessError:
            pass

    return changed


def resolve_tests(changed_files):
    """Map changed source files to candidate test files."""
    matched_tests = set()

    for path in changed_files:
        # If a test file directly changed
        if path.startswith("test/") and path.endswith("_test.dart"):
            if os.path.exists(path):
                matched_tests.add(path)
            continue

        for pattern, tests in MAPPING.items():
            if pattern in path:
                for t in tests:
                    if os.path.exists(t):
                        matched_tests.add(t)

    return sorted(matched_tests)


def main():
    if "--all" in sys.argv:
        cmd = ["flutter", "test", "--exclude-tags", "release_audit,stress"]
        print("Running full fast test suite...")
        sys.exit(subprocess.run(cmd).returncode)

    changed = get_changed_files()
    matched = resolve_tests(changed)

    if "--list" in sys.argv:
        for t in matched:
            print(t)
        return

    if matched:
        print(f"Running {len(matched)} targeted test file(s) for changes:")
        for t in matched:
            print(f"  • {t}")
        cmd = [
            "flutter",
            "test",
            "--exclude-tags",
            "release_audit,stress",
        ] + matched
        sys.exit(subprocess.run(cmd).returncode)
    else:
        print("No specific changed source files matched. Running fast tests...")
        cmd = ["flutter", "test", "--exclude-tags", "release_audit,stress"]
        sys.exit(subprocess.run(cmd).returncode)


if __name__ == "__main__":
    main()
