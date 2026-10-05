# Spacetime Drawing Tool (v6.0.1+2)

An interactive, educational drawing and animation tool for visualizing special
relativity in 1 time $t$ and 2 space $(x,z)* dimensions. It helps students,
teachers, and enthusiasts build intuition around relativistic concepts.

This project is under the Apache License.

---


## 1. What This Project Does

The **Spacetime Drawing Tool** allows you to construct, animate, and explore
spacetime diagrams (Minkowski diagrams) and see how they translate to physical
observations.

### Platforms

* **Web**: The app is hosted at [spacetime.gchouse.org](http://spacetime.gchouse.org).

* **Android*: package name: `org.gchouse.spacetime`.

---

There is a web and Andorid build for this project.

### Storage

* Save user preferences locally.

* Save/load spacetime drawings in **JSON format** (retaining backwards
  compatibility with a previous JavaScript version).

* Enable exporting/saving as downloaded local files or storing in Google Drive
  (with potential future Firebase DB sharing).


### Core Features

* **Spacetime Diagram Canvas (Top Panel)**:

  * Draw the paths (worldlines) of physical entities through space and time.

  * Drag, scale, pan, or zoom into the diagram using mouse or touch gestures.

* **Observer View (Bottom Panel)**:

  * A real-time split-screen simulation demonstrating exactly what an observer
    sees at a selected point in time.

  * Dynamically showcases **length contraction**, **time dilation**, and the
    **relativity of simultaneity** as you alter the observer's velocity.

* **Interactive Controls**:

  * Adjust current observer **Time** and **Velocity** using interactive sliders.

  * Play, pause, or change playback speed to animate the simulation.

  * Relativistic velocity addition is calculated automatically when transforming
    frames.

* **Entity Types (Drawables)**:

  * **Events**: Distinct points in spacetime (e.g., spark flashes).

  * **Light Cones**: Visualizes light signal propagation paths.

  * **Instants**: Tilted lines representing planes of simultaneity.

  * **Locations (Persistent Objects)**: Places objects like trains, barns,
    clocks, flags, or people in motion.

* **Alternative Physics Hypotheses**:

  * Compare standard **Lorentz (Relativity)** transformations (constant speed of
    light) with historical/alternative physics frames: **Ether Frame** (speed of
    light relative to a preferred global frame) and **Emitter Frame** (speed of
    light relative to the source).

* **Save, Load, and Sync**:

  * Save and load scenes to Google Drive.

  * Export/import scenes locally via files or clipboard as JSON.

  * Share scenes easily by copying generated URLs containing serialized state.

  * Full backward compatibility with JSON files saved by the legacy JavaScript
    version.

---

## 2. Building & Running

This project is built using **Flutter**. Make sure you have the [Flutter
SDK](https://docs.flutter.dev/get-started/install) installed.

### Run Locally

To run the app on your local machine (e.g., in Chrome):

```bash
flutter run -d chrome
```

### Run Tests

To execute the unit and integration tests:

```bash
flutter test
```

### Build Production Releases

Use the provided `Makefile` to compile local builds:

```bash
# Build both Web assets and Android APK
make build_all
```

---

## 3. Storage and Google Drive Sync

To support cloud backup and sync, the app integrates with Google Drive API v3.

If you are deploying your own version of this app, configure your credentials by
running:

```bash
flutterfire configure -y
```

---

## 4. License

This project is open-source and licensed under the **Apache 2.0 License**. See
the [LICENSE](LICENSE) file for details.
