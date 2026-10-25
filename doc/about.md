---
title: About Spacetime (v6.1.1+0)
---

The **Spacetime Drawing Tool** is an interactive application designed to teach
and visualize special relativity thought experiments.

It helps you construct diagrams to visualize thought experiments, such as those
presented in Einstein’s book [Relativity][book].

This version was written in Dart with Flutter — the source code is available
on GitHub at [https://github.com/fredgc/spacetime][github].

Found a bug or have a feature request? [File an issue on GitHub][issues].

The previous version (v5) was written in JavaScript. You can still run the
[Version 5 Drawing Tool][v5tool], and audio recordings of lessons from version 5
(not yet ported to version 6) can be found at [Version 5 Help][version5].

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
[issues]: https://github.com/fredgc/spacetime/issues
[v5tool]: https://spacetime.gchouse.org/version5/index.html
[version5]: https://spacetime.gchouse.org/version5/lessons/help.html
