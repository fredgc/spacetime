# Spacetime Project Plan (v6.0.1+2)

This document outlines the roadmap for the **Spacetime** Flutter project.
It is intended as a reminder for the human what we are working on, and
as an explanation for Gemini what we are planning.

Here are some tips:
use /usage to see quota usage.
use /clear to clear ai state between tasks.

### Cleanup and Bug Fix

- [ ] fix broken tests.
   local_file_test.dart: Save/Load Error Details Expansion Verification
   drive_cache_test.dart: DriveTab Widget renders

- [ ] **Style & Code Refactoring**
      - Refactor variable/file names to match standard Dart style guidelines.
      - Make appropriate fields/methods private and split unwieldy classes.

### File Load/Save

- [o] save of unnamed file should turn into save as, instead there is error
      "save failed for empty file". (maybe fixed?)

- [ ] Verify saving json as url works.

- [ ] Don't forget to update google drive api integration after we've published
      the first release. https://console.cloud.google.com/apis/api/drive.googleapis.com/drive_sdk?project=fredgc-spacetime

- [ ] **Counter Increment on Save-As**
      - When doing save-as, check for existing files with same name, increment
        the counter in the name, and give the user a chance to edit it.


### UI, Interaction & Gestures

- [ ] Re-do transform and then check all the mouse and distance computations.
      We want the numbers on the axis to change.


### Correctness

- [X] **Lorentz Transformation & Relativity Physics Unit Tests**
      Verify Lorentz transformation interval invariance, time dilation, length
      contraction, velocity addition, relativity of simultaneity, and light cone slope.

### Path Objects

Create objects that have variable velocity.

### Help Pages

Write a few help pages to explain how to use the tools.

- side view versions space-time view.

- File save/load for upload/download or drive.

- object creation and properties.

- veolicty and time sliders, animation.

### Tutorials

Design a tutorial system that prompts the user to use the controls. This would
be similar to the way a game tutorial works. A tutorial would be a sequence of
steps that have prompt that tells the user what to do. A control
(button/slider/etc) or object would be highlighted until the user does an
action, like click on the button or adjust the slider.


Look up the old tutorials and make sure they are all covered. The list would
include:

- Basic control usage, including the different speed-of-light assumptions.

- contraction/dilation

- Train entering a barn paradox.

- twin paradox

### Dynamic Files

Research collaborative editing where two users can edit the same file
simultaneously and see real-time updates.

One option is to store the scene in a google sheet.  Explore saving individual
objects as spreadsheet rows (Google Sheets) or Firebase Realtime Database
records.

Another option is to use a firebase db. Sharing would require recreating Google
drive files access?

Research pricing, limits, and monetization schemes to support
free/cheap tiers.


### Android Release

- Document publishing new versions of the web app to `spacetime.gchouse.org`.

- Document building and publishing the Android package (`org.gchouse.spacetime`).
