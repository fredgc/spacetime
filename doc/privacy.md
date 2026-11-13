# Privacy Policy for Spacetime Drawing Tool

*Last Updated: October 31, 2026*

---

## Zero-PII & Privacy by Design

The **Spacetime Drawing Tool** ("the App") is an interactive educational
application designed to construct, explore, and visualize special relativity
thought experiments. We adhere to strict **Privacy by Design**: we do not
collect personal information, we do not require account registration to use
the tool, we do not track you across websites, and we do not sell or monetize
user data.

This application is built for students, teachers, researchers, and relativity
enthusiasts of all ages.

---

## Information We Do NOT Collect

To maintain a zero-PII (Personally Identifiable Information) architecture:

* **No Mandatory User Accounts:** You can create, edit, animate, and download
  spacetime diagrams without registering an account.

* **No Device Sensors or Invasive Permissions:** The App does not access
  device location (GPS), camera, microphone, contacts, or biometric sensors.

* **No Advertising or Cross-Site Tracking:** The App is completely ad-free and
  contains no advertising networks, marketing trackers, or commercial
  analytics SDKs.

---

## Data Handled by the Application

### 1. Local Settings & Preferences

* Settings such as your preferred theme mode (light, dark, or system), grid
  visibility, animation playback speed, and transformation view options are
  stored exclusively on your device using browser `localStorage` (on the Web)
  or `SharedPreferences` (on Android/Desktop).

* On Web, clearing your browser application data deletes these preferences. On
  Android, uninstalling the app removes all stored preferences.

### 2. Diagram Files & Storage

* **Local Device Storage:** Spacetime diagram files (`.json`) can be
  downloaded and opened directly on your local device.

* **Optional Google Drive Integration:** If you choose to connect your Google
  Drive account to save or open diagrams, the App uses the official Google
  Drive API solely to access files created by or explicitly opened with this
  App. No diagram contents, credentials, or file metadata are ever transmitted
  to or stored on `gchouse.org` servers.

* **Shared Links:** If you share a diagram URL containing serialized scene
  data, that data is encoded directly into the URL fragment and processed
  locally by the recipient's browser.

---

## Third-Party Infrastructure

The App is hosted statically using **Google Firebase Hosting** (Google LLC):

* Standard technical connection metadata (such as IP addresses and HTTP
  request headers) is processed temporarily by Google Cloud infrastructure
  strictly for routing, security, and denial-of-service prevention.

* For more information on Google's privacy practices, see the
  [Google Privacy Policy](https://policies.google.com/privacy) .

---

## Children & Classroom Safe (COPPA & FERPA)

The App is designed to be fully compliant with educational privacy
regulations:

* **COPPA (Children’s Online Privacy Protection Act):** The App does not
  collect personal information from children under 13.

* **FERPA (Family Educational Rights and Privacy Act):** Because no student
  education records or personal identifiers are collected, maintained, or
  shared, the App can be safely used in K-12 and university classroom
  environments.

---

## Questions & Contact

The Spacetime Drawing Tool is an open-source educational project. If you have
questions or feedback regarding this Privacy Policy:

* **File an Issue on GitHub:**
  [https://github.com/fredgc/spacetime/issues](https://github.com/fredgc/spacetime/issues)

* **Visit GC House:** [https://www.gchouse.org](https://www.gchouse.org)
