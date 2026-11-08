# Spacetime Project Plan (v6.1.4+0)

This document outlines the strategic roadmap, architecture goals, and long-term
milestones for the **Spacetime** Flutter project.

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

* **Backend Storage**:
  Evaluate storing scene objects as rows in Google Sheets or documents in
  Firebase Realtime Database / Firestore.

* **Permissions & Access Control**:
  Investigate how Firebase access rules integrate with Google Drive OAuth
  sharing permissions.

* **Quotas & Cost Modeling**:
  Establish quotas, free tier boundaries, and storage limits for cloud-synced
  collaborative scenes.

---

## 3. Path Objects & Generalized Worldlines

* **Variable Velocity Worldlines**:
  Implement worldline path objects defined by piecewise linear or spline
  segments to model acceleration and multi-stage motion.

* **Curved Spacetime Explorations**:
  Investigate pedagogical visualizations for accelerated frames (Rindler
  coordinates) and uniform gravitational fields.

---

## 4. Enhanced Interactive Tutorials

* **Snap-to-Target Interaction**:
  Implement magnetic snapping when users drag or manipulate sliders and canvas
  objects close to tutorial target coordinates.

* **Additional Scenarios**:
  Create comparative tutorials illustrating moving observers under Ether and
  Emitter physics hypotheses.

---

## 5. Deployment and Publishing Infrastructure

* Maintain automated release workflows via `Makefile` (`make stage`,
  `make release`).

* Document cross-platform build and release procedures for both web hosting and
  mobile app stores.
