---
title: About Spacetime (v6.0.1+2)
---

The **Spacetime Drawing Tool** is an interactive application designed to teach
and visualize special relativity thought experiments.

It helps you construct diagrams to visualize thought experiments, such as those
presented in Einstein’s book [Relativity][book].

This version was written in Dart with Flutter — the source code is available on GitHub at
[https://github.com/fredgc/spacetime][github].
The previous version (v5) was written in JavaScript. Audio recordings of lessons from
version 5 have not yet been ported to version 6, but you can find them at
[Version 5 Help][version5].

## Privacy and Data Retention

This program allows you to customize settings that are saved locally on your
device (using SharedPreferences / LocalStorage). No personal data is collected.

On Android, local settings are deleted when you uninstall the app. On Web,
settings are deleted when you clear your browser's local application data.

Drawings may be downloaded to your local device or saved to your Google Drive
account. You may also load drawings shared by others, but no files are sent to
the `gchouse.org` server.

[book]: https://en.wikipedia.org/wiki/Relativity:_The_Special_and_the_General_Theory
[github]: https://github.com/fredgc/spacetime
[version5]: /version5/lessons/help.html
