# GEMINI.md - Developer Guide for Spacetime Drawing Tool

Welcome! This guide is designed to help future LLM agents and human developers
get up to speed quickly on the **Spacetime** Flutter application.

Build Version v6.1.1+0

---

## 1. Project Purpose & Features

The Spacetime Drawing Tool is an interactive, cross-platform (Web and Android)
application used to teach and visualize special relativity in 1 space dimension
($x$) and 1 time dimension ($t$).

### Key Features

* **Relativistic Transformations**: Visualize spacetime coordinates under
  different physical assumptions:

  * **Lorentz (Relativity)**: Constant speed of light ($c$) in all reference
    frames.

  * **Ether**: Speed of light is relative to a preferred global frame.

  * **Emitter Speed**: Speed of light is relative to its source emitter.

* **Interactive Spacetime Diagram**: View worldlines, events, light cones, and
  planes of simultaneity.

* **Observer View (Side View)**: A split-screen panel showing what the observer
  sees at the current instant of time, illustrating length contraction, time
  dilation, and the relativity of simultaneity.

* **Interactive Tutorials & Step-by-Step Lessons**: Guided interactive
  lessons with dynamic UI highlights, criterion verification, automated
  actions ("Do it for me"), and progress tracking.

* **File Management**: Save/load scenes as JSON locally (files/clipboard) or
  synced to Google Drive.

* **Backward Compatibility**: Fully compatible with file saves from an older
  JavaScript version of the tool.

* **Undo/Redo & Unsaved State Sync**: History tracking of edits, object
  additions, colors, name changes, and movements synchronized with file save
  checkpoints and unsaved state warnings.

---

## 2. Codebase Architecture

```mermaid
graph TD
    Main["main.dart"] --> MyApp["my_app.dart"]
    MyApp --> GoRouter["GoRouter Navigation"]
    GoRouter --> SplashWidget["widget.dart: SplashWidget"]
    SplashWidget --> AppWidget["widget.dart: AppWidget"]

    AppWidget --> SceneView["scene.dart: SceneView"]
    AppWidget --> FileManager["file_manager.dart: FileManager"]
    AppWidget --> TutorialCard["tutorial_widget.dart: TutorialCard"]

    SceneView --> SceneData["scene.dart: SceneData"]
    SceneView --> UndoManager["edit.dart: MyUndoManager"]
    SceneView --> CoordTransform["transform.dart: CoordinateTransform"]

    SceneData --> Drawables["drawable.dart: Drawable"]
    FileManager --> FileHolder["file_holder.dart: FileHolder"]
    FileManager --> DriveAccess["drive.dart: MyDriveAccess"]
    FileManager --> TutorialCtrl["script.dart: TutorialController"]
```

### Core Components

* **`lib/main.dart`**: Entrypoint. Initializes Flutter and runs
  `MyApp.fullApp()`.

* **`lib/my_app.dart`**: Sets up global theme, JS interop, routes (via
  `GoRouter`), and serves top-level screens.

* **`lib/widget.dart` & `lib/widgets/`**:

  * [SplashWidget](lib/widgets/splash_widget.dart#L16):
    Wraps loading states (settings, sprites, file initialization).

  * [AppWidget](lib/widgets/app_widget.dart#L24):
    Primary editor interface. Contains App Bar, toolbar, and layout columns,
    wrapped in `PopScope` to intercept back gestures when unsaved edits exist.

  * [TapToEditText](lib/widgets/tap_to_edit.dart#L7):
    Inline editing textfield with escape-key and keyboard handling.

  * [JsonSyntaxEditorDialog](lib/widgets/json_syntax_dialog.dart#L6):
    Live JSON syntax correction dialog.

  * Sliders (`MySlider.buildTable`): Handles interactive sliders for changing
    current observer time ($t$) and velocity ($v$).

  * Overlays: Mounts `TutorialHighlightLayer`, `TutorialCard`, and canvas
    overlays when a tutorial is active.

* **`lib/scene.dart` & `lib/scene/`**:

  * [SceneData](lib/scene/scene_data.dart#L13):
    Serialized document state (list of drawables, time, velocity, viewport
    center/zoom).

  * [SceneView](lib/scene/scene_view.dart#L23):
    High-level state manager for the active editor. Coordinates painting,
    selections, tool choices, and contains a `Worker` to dispatch asynchronous
    drawable calculations.

  * [ScenePainter & SideViewPainter](lib/scene/scene_painters.dart#L5):
    Custom painters connecting Flutter canvas repaints to `SceneView`.

* **`lib/transform.dart`**:

  * Coordinate math. Models `Point`, `Vector`, `ReferenceFrame` (defining
    velocity $v$ and Lorentz gamma $\gamma = 1 / \sqrt{1 - v^2}$), and
    `CoordinateTransform` which handles scaling, zooming, panning, and
    conversions between World, Observer, and Screen coordinate spaces.

* **`lib/drawable.dart` & `lib/drawables/`**:

  * Models entity types placed in spacetime (inheriting from `Drawable`):

    * [Event](lib/drawables/event.dart#L22):
      A single coordinate point. Fades out in side view over time.

    * [LightCone](lib/drawables/light_cone.dart#L22):
      Expands outward along light paths.

    * [Instant](lib/drawables/instant.dart#L22):
      Tilted plane of simultaneity.

    * [Location](lib/drawables/location.dart#L23):
      Moving entities (Person, Train, Barn, Flag, Clock) represented by
      worldlines. These render as length-contracted sprites in the side view.

* **`lib/script.dart` & `lib/script/` & `lib/tutorial_widget.dart`**:

  * Interactive tutorial engine. Parses markdown tutorials and directives
    (`TutorialDirective`), evaluates conditions against `SceneView`, and
    renders floating `TutorialCard`, canvas overlays, and UI highlights:

    * [TutorialParser](lib/script/tutorial_parser.dart#L27): Markdown parser.

    * [TutorialStep](lib/script/tutorial_step.dart#L446): Step evaluation and
      `TutorialDirective` classes.

    * [TutorialController](lib/script/tutorial_controller.dart#L9): Reactive
      controller tracking progress and driving step criteria.

* **`lib/drive.dart` & `lib/drive/`**:

  * Google Drive v3 REST API integration, OAuth authentication, query
    parsing (`buildDriveQuery`), and file picker dialogs:

    * [MyDriveAccess](lib/drive/drive_auth.dart#L18): Authentication manager,
      OAuth token storage, sign in/out, and status stream.

    * [DriveHolder](lib/drive/drive_service.dart#L44): FileHolder storage
      driver for Google Drive files and metadata.

    * [DriveDialog](lib/drive/drive_dialog.dart#L11): Drive file picker and
      search dialog UI.

* **`lib/splitter.dart`**:

  * Splitscreen widget (`SplitterWidget`) rendering main spacetime canvas
    on top and observer side view on the bottom with a draggable divider.

* **`lib/axis.dart`**:

  * `PlotAxis` handles coordinate grid calculation, rounding bounds, and
    drawing axis ticks and labels on canvas.

* **`lib/sprites.dart`**:

  * Sprites and vector silhouettes for observer entities (Person, Train, Barn,
    Flag, Clock).

* **`lib/color.dart`**:

  * Color management (`SavableColor`, `SavableColorArray`, and `SavableTheme`).

* **`lib/animate.dart`**:

  * `MyAnimator` timing loop powering continuous time advancement.

* **`lib/file_manager.dart`**:

  * Manages active `FileHolder`, dirty/unsaved states, recent files list,
    active tutorials, and triggers `checkSave` dialogs for destructive actions.

* **`lib/file_holder.dart`**:

  * Storage driver interface (`DriveHolder`, `JsonHolder`, `ClipboardHolder`,
    `LocalFileHolder`).

* **`lib/drive.dart`**:

  * Google Drive v3 REST API integration, OAuth authentication, query
    parsing (`buildDriveQuery`), and file picker dialogs.

* **`lib/edit.dart`**:

  * Core undo/redo infrastructure (`MyUndoManager`, `UndoCallback`, `Change`).

---

## 3. Math & Physics Conventions

Coordinate conversions are implemented in `lib/transform.dart`. Special
relativity math is defined by:

* Speed of light $c = 1.0$.

* Relative velocity $v$ ranges within $[-0.999, 0.999]$.

* Lorentz factor $\gamma = \frac{1}{\sqrt{1 - v^2}}$.

### Lorentz Frame Transform (World Frame $\leftrightarrow$ Reference Frame)

Transform from observer frame to world frame:

$$x_0 = \gamma (x + v t)$$

$$t_0 = \gamma (t + v x)$$

Transform from world frame to observer frame:

$$x = \gamma (x_0 - v t_0)$$

$$t = \gamma (t_0 - v x_0)$$

In code (see [Point.toFrame](lib/transform.dart#L49)):

```dart
double x0 = frame.gamma * (x - frame.velocity * t);
double t0 = frame.gamma * (t - frame.velocity * x);
```

### Length Contraction

For `Location` entities, visual width in the side view is length-contracted
based on relative velocity to the observer (see
[Location.update](lib/drawable.dart#L565)):

```dart
double v = frame.velocity;
double u = transform.frame.velocity;
double w = (v - u) / (1.0 - u * v); // Relative velocity addition formula
double gammaInv = math.sqrt(1.0 - w * w);
contracted_width = width * gammaInv;
```

---

## 4. Interactive Tutorial System

The application includes an interactive tutorial engine (`lib/script.dart` and
`lib/tutorial_widget.dart`) that presents step-by-step physics lessons with
live verification against user actions.

### Tutorial Markdown Schema

Tutorials are written in markdown and parsed by `Tutorial.fromMarkdown()`:

* **Title**: Single top-level `# Tutorial Title`.

* **Description**: Introductory paragraphs preceding the first step.

* **Steps**: Numbered headings `## 1. Step Title`.

* **Body**: Explanatory text and instructions shown on the `TutorialCard`.

* **Directives**: Blockquote lines (`> ...`) defining interactive criteria:

  * `> v = 0.5 [tol 0.02]`: Checks velocity slider target.

  * `> t = 2.0 [tol 0.1]`: Checks time slider target.

  * `> mode = lorentz|ether|emitter`: Checks light speed frame mode.

  * `> tool = select|add`: Checks active toolbar tool.

  * `> type = person|train|barn|flag|clock|event|cone|instant`: Checks type.

  * `> name = TargetName`: Checks object name in toolbar or selection.

  * `> color = 0..9`: Checks selected color index.

  * `> add = type [x, t]`: Guides user to place an object near coordinates.

  * `> select = name|type`: Requires selecting an object.

  * `> load = filename`: Loads a preset scene for the step.

  * `> setup ...`: Background setup actions applied on step start.

  * `> ok`: Informational step requiring manual confirmation.

### Controller & Evaluation Lifecycle

1. `FileManager.activeTutorial` holds the active `TutorialController`.

2. The controller tracks `currentStepIndex` and listens to `SceneView` state.

3. On slider changes or canvas edits, `TutorialStep.isSatisfied(scene)`
   evaluates all step directives.

4. If all directives are satisfied, the step status turns green and enables
   advancing.

5. Directives supporting automated actions (`canDoItForMe == true`) allow users
   to tap "Do it for me", executing `applyDoItForMe(scene)` to automatically
   adjust sliders or tools to the required target.

6. The user can navigate backward ("Back"), advance ("Continue"), or close
   ("Exit") at any time.

### UI Architecture & Highlights

* **`TutorialCard`**: Draggable, floating overlay card displaying step
  instructions, target status, and navigation buttons.

* **`TutorialHighlight`**: Wraps target UI controls (sliders, tool buttons,
  menus) and renders animated pulsing highlight frames when their `highlightId`
  matches the active step's target.

* **`TutorialCanvasOverlay`**: Renders placement targets or pointer hints
  directly on the spacetime canvas during object placement steps.

---

## 5. Key Workflows

### Loading a Scene

1. `FileManager.loadFile()` is called with a `FileHolder`.

2. Navigation url is updated via `go_router`.

3. `FileManager.reload()` asynchronously loads raw JSON string via
   `FileHolder.loadData()`.

4. `SceneData.fromJsonString()` parses content, detecting modern or legacy
   schema.

5. A new `SceneView` is created, and `SplashWidget` switches to rendering
   `AppWidget`.

### Modifying and Repainting

1. User adjusts a slider or clicks/drags.

2. Changes to velocity trigger `SceneView.updateScene()`.

3. The `Worker` executes asynchronously to update all drawables (computing
   their coordinates in the observer frame).

4. `SceneView.requestRepaintScene()` is called, incrementing `repaintCounter`.

5. CustomPainters (`ScenePainter` and `SideViewPainter`) listen to
   `repaintCounter` and trigger canvas repaints.

---

## 6. Development Checklist & Gotchas

* **Asynchronous Repaints**: Repainting uses a `Worker` class
  (`lib/worker.dart`) to avoid blocking UI during frame updates. Do not call
  `setState()` directly for heavy calculations; use `updateScene()`.

* **State Syncing**: `AppWidget` uses multiple `ValueNotifier` and
  `ListNotifier` instances. When adding new settings, remember to register them
  in `Settings` so they are saved to `SharedPreferences`.

* **Deep Links**: When launching from deep links (e.g.
  `spacetime.gchouse.org/#/scene?json=...`), `FileManager` handles
  `checkNavigation` during `GoRouter` updates.

* **Test Isolation**: Integration tests in `test/` mock file loading and
  settings using wrappers. Ensure you clean up listeners in `dispose()` methods
  to prevent test leakage.

* **Remote Logging**: `RemoteLogger` (in `lib/printer.dart`) sends HTTP logs to
  a local logging server when running on web (controlled via `remote_logging`
  setting). Start logging server by running:

  ```bash
  python3 log_server.py
  ```

  This server runs on port 5001 and writes client logs to `client_logs.log` and
  standard output.

* **Drive Auth & Token Invalidation**: `MyDriveAccess` (`lib/drive.dart`)
  clears cached credentials on sign-in if Drive scopes are missing, and
  automatically clears tokens and demotes status to `LoggedIn` upon
  encountering 401, 403, or `invalid_token` API errors.

* **Drive File Search & Query Parsing**: `DriveState` (`lib/drive.dart`) has
  a search input (`ValueKey('drive-search-input')`) persisting across dialog
  opens in a session. `buildDriveQuery()` converts title terms into
  `name contains '...'` clauses, maps `owner:me` / `owner:email` into
  `'me' in owners`, and supports raw Google Drive API query expressions.

* **Title & Metadata Sync**: `SceneData.title` and `SceneData.description`
  remain synchronized with `FileHolder.title` and Google Drive file metadata
  (`request.name`, `request.description`, `request.mimeType`). Opening a
  `DriveHolder` overrides the title stored in JSON with the Drive file name.

* **Web Asset Cache-Busting & Help Reloading**: Web assets are requested with
  version tags (`?v=$versionTag`). `HelpScreen` (`lib/help.dart`) scans loaded
  help HTML for version headers (`v2.1.0+XX`). If a stale version string
  is detected, it issues a forced `no-cache` fetch to reload the asset.

* **Mouse Drag Viewport Jump Prevention**: Single-pointer panning and object
  moving in `lib/mouse.dart` initialize focal points at gesture start without
  applying an initial frame-1 movement jump. Movement deltas are computed
  dynamically during `onScaleUpdate`.

* **Unsaved State & Undo Checkpoint Sync**: `MyUndoManager` tracks a
  `_savedIndex`. When undoing back to the last save point, `unsaved.value` is
  automatically set to `false`. Navigating to auxiliary screens (`/help`,
  `/about`, `/settings`) preserves the active drawing in memory without
  prompting. Web `beforeunload` interop (`web/extra_js_interface.js`) prompts a
  browser leave-site warning when `unsaved` is true.

* **JSON Error Recovery & Syntax Editor**: `FileManager` retains `rawBlob` on
  parse failures and provides `loadFromRawJson(String rawJson)`. `SplashWidget`
  displays an "Edit JSON Syntax" button launching `JsonSyntaxEditorDialog` for
  live syntax correction and inline validation.

* **Theme Palette Synchronization**: `SavableColorArray.updateTheme` duplicates
  color schemes with `List.from(...)` to prevent in-place mutation of static
  defaults. `AppWidgetState` listens to `widget.settings.statusStream()`
  to trigger canvas repaints and WebView theme class toggles
  (`light-theme`/`dark-theme`).

* **Settings Layout & Responsive Reflow**: `SettingsScreen`
  (`lib/settings.dart`) uses `Wrap` widgets with constrained input width
  controls (`SizedBox`) to prevent horizontal `RenderFlex` overflows on narrow
  mobile screens. `MyIterator` dynamically filters out empty widget sublists
  produced by hidden `debug_only` settings or `EndOfRow` breaks, preventing
  empty rows and phantom dividers.

* **Viewport Bounds & Initial Scale**: `CoordinateTransform`
  (`lib/transform.dart`) defaults to `zoom = 100.0` pixels per world unit with
  origin centered at `(width / 2, height / 2)`. Screen range bounds ($x$
  and $t$) are derived dynamically from container size passed during
  `LayoutBuilder` `resize()` calls in `SceneView.build` (`lib/scene.dart`).

* **Window Size in Tests**: In widget test harnesses, avoid deprecated
  `tester.binding.window` APIs; use `tester.view.physicalSize` and
  `tester.view.devicePixelRatio`.

---

## 7. Code Style

### Markdown Preferences

To maintain clean and standardized documentation for both developers and
automated builders (such as `pandoc`):

* Keep line lengths less than 80 characters.

* Always follow headers with a blank line.

* Surround all list items and code blocks with blank lines.

### Dart Preferences

To ensure clean and standard Dart syntax across the project:

* After editing or creating any Dart files, format the code by executing:

  ```bash
  dart format .
  ```

### Git Commit Preferences

To ensure clean and standard commit logs:

* Write commit messages using the following structure:

  ```text
  Version $version. <major fixes>

  <description of minor and major fixes>
  ```

* Keep line lengths in commit messages under 70 characters.

---

## 8. Testing Guidelines

To maintain fast feedback loops, run targeted tests depending on which files
are modified. Only run the entire test suite (`flutter test`) before doing a
git commit or staging a release.

*   **Name Validation** (`lib/name.dart`)

    Run: `flutter test test/name_test.dart`

*   **Routing & Navigation** (`lib/navigation.dart`, `lib/my_app.dart`)

    Run: `flutter test test/nav_test.dart`

*   **Upload & Clipboard** (`lib/upload.dart`)

    Run: `flutter test test/upload_test.dart`

*   **JSON & Scene Serialization** (`lib/scene.dart`)

    Run: `flutter test test/json_test.dart`

*   **Coordinate Math** (`lib/transform.dart`)

    Run: `flutter test test/transform_test.dart`

*   **Relativity Physics Correctness**
    (`lib/transform.dart`, `lib/drawable.dart`)

    Run: `flutter test test/relativity_test.dart`

*   **Spacetime Entities / Drawables** (`lib/drawable.dart`)

    Run: `flutter test test/simple_test.dart test/scene_editor.dart`

*   **Axes & Grid Lines** (`lib/axis.dart`)

    Run: `flutter test test/axis_test.dart`

*   **Sprites & Silhouettes** (`lib/sprites.dart`)

    Run: `flutter test test/sprites_test.dart`

*   **Split Screen Layout** (`lib/splitter.dart`)

    Run: `flutter test test/splitter_test.dart`

*   **Colors & Themes** (`lib/color.dart`)

    Run: `flutter test test/color_test.dart`

*   **Undo/Redo History & Unsaved Sync** (`lib/edit.dart`)

    Run: `flutter test test/edit_test.dart`

*   **File IO & Recent Files**
    (`lib/file_manager.dart`, `lib/file_holder.dart`,
    `lib/local_file.dart`, `lib/recent_file.dart`)

    Run: `flutter test test/local_file_test.dart`

*   **Drive Authentication & Token Caching** (`lib/drive.dart`)

    Run: `flutter test test/drive_cache_test.dart`

*   **Mouse Clicks & Drags** (`lib/mouse.dart`)

    Run: `flutter test test/mouse_test.dart`

*   **Velocity & Time Sliders** (`lib/slider.dart`)

    Run: `flutter test test/slider_test.dart`

*   **Settings Management** (`lib/settings.dart`)

    Run: `flutter test test/settings_test.dart`

*   **Background Worker** (`lib/worker.dart`)

    Run: `flutter test test/worker_test.dart`

*   **Interactive Scripts & Tutorials**
    (`lib/script.dart`, `lib/tutorial_widget.dart`)

    Run: `flutter test test/script_test.dart test/tutorial_test.dart`

*   **Animation Timing & Helpers** (`lib/animate.dart`)

    Run: `flutter test test/async_test.dart test/animator_test.dart`

*   **Printer & Logging Utilities** (`lib/printer.dart`)

    Run: `flutter test test/printer_test.dart`

*   **General UI / Layout** (`lib/widget.dart`)

    Run: `flutter test test/widget_test.dart test/layout_test.dart`

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>
<script>
  mermaid.initialize({ startOnLoad: true, theme: 'default' });
</script>
