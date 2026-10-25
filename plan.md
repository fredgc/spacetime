# Spacetime Project Plan (v6.1.1+0)

This document outlines the roadmap for the **Spacetime** Flutter project.
It is intended as a reminder for the human what we are working on, and
as an explanation for Gemini what we are planning.

Here are some tips:

- use `/usage` to see quota usage.

- use `/clear` to clear ai state between tasks.


### Cleanup and Bug Fix

- trying to open a file via drive gave oauth error. investigate.

### Android

- Build and test android version.

- Release android version to play store.


### File Load/Save

- [ ] Don't forget to update Google Drive API integration after we've published
      the first release:
      https://console.cloud.google.com/apis/api/drive.googleapis.com/drive_sdk?project=fredgc-spacetime


### UI, Interaction & Gestures


### Path Objects

- [ ] Create objects that have variable velocity (worldline paths with multiple
      points).


### Dynamic Files

Research collaborative editing where two users can edit the same file
simultaneously and see real-time updates:

- [ ] Explore storing scenes in a Google Sheet (saving individual objects as
      spreadsheet rows) or Firebase Realtime Database records.

- [ ] Explore Firebase DB sharing and how permissions interact with Google
      Drive file access.

- [ ] Research pricing, limits, and monetization schemes to support free/cheap
      tiers.


### Web & Android Release

- [ ] **Pre-Release Verification & Staging Checklist**

  - [ ] **Synchronize Assets & Documentation**:
    Run `make docs` and `python3 generate_tutorials.py` to ensure all
    markdown docs compile to HTML in `assets/dev/` and tutorials are updated.

  - [ ] **Deploy to Staging Preview**:
    Run `make stage` (with `DEBUG_ENABLED=true`) or `make stage-release` to
    push to the staging preview channel
    (`https://fredgc-spacetime--staging-hfoxw6cy.web.app`).

  - [ ] **Manual Staging Verification**:

    - **Tutorial Flow & Markdown**: Confirm rich typography (bold, italics,
      bullets) renders without raw markdown tokens. Verify animated pulsing
      highlights, card dragging/minimization, and "Do it for me".

    - **Google Drive Authentication**: Verify Google Sign-in on web, saving
      diagrams, search query parsing (`owner:me`, partial names), and session
      persistence across reloads.

    - **Unsaved State & Navigation**: Verify leave-site warnings on unsaved
      edits, dialog confirmation on file changes, and unsaved state clearance
      on undo back to save checkpoints.

    - **Version & Debug Docs Visibility**: Verify the Help menu displays the
      active version (`About Spacetime v${settings.fullVersion}`) matching
      `pubspec.yaml`, and Developer Docs appear when "Enable Debug Mode" is
      toggled in Settings (under `DEBUG_ENABLED=true`).

    - **Layout & Animations**: Drag the split screen divider, advance time
      animation ($t$), switch relativity modes (Lorentz/Ether/Emitter), and
      verify narrow mobile viewport reflow without overflow errors.

  - [ ] **Recommended Additional Automated Tests**:

    - `JsonSyntaxEditorDialog`: Verify interactive error banners on malformed
      JSON and successful load on correction.

    - Tutorial Undo: Verify undoing object placement during a tutorial step
      reverts satisfaction status and disables advancing.

    - Help Menu Version: Verify dynamic version string rendering without
      hardcoded version fallbacks.

  - [ ] **Production Release Execution**:
    Run `make release` (which invokes `./roll_build_number.sh --release`,
    `make build_all`, and `firebase deploy`) to publish to
    `spacetime.gchouse.org`.

- [ ] Document publishing new versions of the web app to
      `spacetime.gchouse.org`.

- [ ] Document building and publishing the Android package
      (`org.gchouse.spacetime`).
