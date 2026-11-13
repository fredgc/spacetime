# Spacetime Project Plan

This document outlines the strategic roadmap, architecture goals, and
long-term milestones for the **Spacetime** Flutter project.

> **Note**: Tactical day-to-day tasks and active issue tracking are managed
> dynamically using `~/bin/todo.py`. Run `~/bin/todo.py list` to view active
> tasks.

---

## 1. Android Release & Store Publishing

* Build and test on real Android devices via `adb`.

* Configure store assets, screenshots, and metadata.

* Submit and publish release bundle to Google Play (`org.gchouse.spacetime`).

---

## 2. Dynamic Files & Real-Time Collaboration

Research and prototype multi-user collaborative editing where multiple users
can view and edit a shared spacetime diagram simultaneously:

* **Backend Storage**: Evaluate storing scene objects as rows in Google Sheets
  or documents in Firebase Realtime Database / Firestore.

* **Permissions & Access Control**: Investigate how Firebase access rules
  integrate with Google Drive OAuth sharing permissions.

* **Quotas & Cost Modeling**: Establish quotas, free tier boundaries, and
  storage limits for cloud-synced collaborative scenes.

---

## 3. Path Objects & Generalized Worldlines

* **Variable Velocity Worldlines**: Implement worldline path objects defined
  by piecewise linear or spline segments to model acceleration and multi-stage
  motion.

* **Curved Spacetime Explorations**: Investigate pedagogical visualizations
  for accelerated frames (Rindler coordinates) and uniform gravitational
  fields.

---

## 4. Enhanced Interactive Tutorials

* **Snap-to-Target Interaction**: Implement magnetic snapping when users drag
  or manipulate sliders and canvas objects close to tutorial target
  coordinates.

* **Additional Scenarios**: Create comparative tutorials illustrating moving
  observers under Ether and Emitter physics hypotheses.

---

## 5. Deployment and Publishing Infrastructure

* Maintain automated release workflows via `Makefile` (`make stage`, `make
  release`).

* Document cross-platform build and release procedures for both web hosting
  and mobile app stores.

---

## 6. Visual & Accessibility Verification Checklist

Perform these manual checks across supported locales (`en`, `en_GB`, `de`,
`es`, `fr`, `ja`, `lt`, `pt`, `zh`) on mobile and desktop viewports:

* **Minkowski Canvas & Diagram**:

  * [ ] Verify worldlines, grids, and light cones render crisply in both light
        and dark themes.

  * [ ] Verify hyperbolic calibration curves and grid coordinate labels do not
        overlap or clip when zooming or boosting velocity.

* **Lorentz Boost & Motion Controls**:

  * [ ] Drag velocity slider ($v$) from $-0.99$ to $+0.99$ and verify grid
        shear and clock rotations animate smoothly without visual jitter.

  * [ ] Drag time slider ($t$) and verify train positions, emitter pulses, and
        moving clock faces remain aligned with worldlines.

* **Interactive Tutorials (Tutorials 01–07)**:

  * [ ] In Tutorial 02, verify localized station names and drinks appear
        correctly for the active language:

    * `en` (US): Grand Central Station, coffee

    * `en_GB` (UK): Trafalgar Station, tea

    * `de`: Berliner Hauptbahnhof, Bier

    * `es`: Estación de Atocha, café

    * `fr`: gare de Lyon, café

    * `ja`:東京駅,お茶

    * `lt`: Vilniaus geležinkelio stotis,šaltibarščiai

    * `pt`: Estação Central, café

    * `zh`:北京站,茶

  * [ ] Verify step navigation buttons (Next, Previous, Reset) do not truncate
        or wrap awkwardly in German, French, or Lithuanian.

* **Language Menu & Navigation**:

  * [ ] Switch to each language from the top bar language menu and confirm all
        UI labels, dialog headers, and tooltips update instantly.

  * [ ] Switch to **Auto** and verify the app reverts cleanly to the system
        default locale.

* **Screen Reader & Focus**:

  * [ ] Enable TalkBack (Android) or VoiceOver (iOS/macOS) and navigate
        through the top bar controls, velocity slider, and tutorial step
        cards.
