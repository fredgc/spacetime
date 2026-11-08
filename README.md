# Spacetime Drawing Tool (v6.1.4+0)

An interactive, educational drawing and animation tool for visualizing special
relativity in 1 time ($t$) and 2 space ($x, z$) dimensions. It helps students,
teachers, and enthusiasts build intuition around relativistic concepts.

* **Live Web App**: [spacetime.gchouse.org](https://spacetime.gchouse.org)

* **Android Package**: `org.gchouse.spacetime`

---

## Documentation

Comprehensive documentation is available in the `doc/` directory:

* [doc/about.md](doc/about.md): Project origins, author attribution, and
  version history.

* [doc/overview.md](doc/overview.md): Mathematical and physical principles of
  Minkowski spacetime diagrams.

* [doc/controls.md](doc/controls.md): Guide to the toolbar, velocity sliders,
  playback controls, and gestures.

* [doc/objects.md](doc/objects.md): Spacetime entities including events,
  light cones, instants, and persistent locations.

* [doc/transformations.md](doc/transformations.md): Comparative physics models
  (Lorentz Relativity, Ether, Emitter frame).

* [doc/files.md](doc/files.md): Saving, loading, JSON schema, and Google Drive
  synchronization.

* [doc/privacy.md](doc/privacy.md): Application privacy policy and local
  storage disclosure.

* [doc/terms.md](doc/terms.md): Terms of service.

---

## Core Features

* **Spacetime Diagram Canvas**:
  Draw worldlines of physical entities across space and time. Scale, pan, and
  zoom dynamically.

* **Observer View**:
  Split-screen real-time simulation displaying what an observer sees at the
  selected coordinate time, illustrating length contraction, time dilation,
  and the relativity of simultaneity.

* **Interactive Tutorials**:
  Guided interactive lessons with UI highlight targets, automatic verification,
  and step-by-step instructions.

* **Comparative Hypotheses**:
  Examine coordinate frames under Lorentz relativity (constant speed of light),
  Ether drift (preferred rest frame), or Emitter ballistics.

* **Save, Load, and Cloud Sync**:
  Store scenes locally in JSON format (fully backward-compatible with legacy
  editions) or sync across devices using Google Drive.

---

## Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install)
  (3.24+ recommended)

* `make` and [Pandoc](https://pandoc.org/) (for compiling documentation assets)

### Forking and Cloning

1. Fork the repository on GitHub to your personal account.

2. Clone your fork locally:

   ```bash
   git clone https://github.com/<your-username>/spacetime.git
   cd spacetime
   ```

3. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

4. Compile documentation and asset bundles:

   ```bash
   make docs
   ```

### Running Locally

To run the web version in Chrome:

```bash
flutter run -d chrome
```

To run on a connected Android device or emulator:

```bash
flutter run -d android
```

### Running Tests

Execute the unit and widget test suite:

```bash
flutter test
```

### Building Releases

Use the provided `Makefile` to generate release assets:

```bash
make build_all
```

---

## License

This project is open source and licensed under the
[Apache 2.0 License](LICENSE).
