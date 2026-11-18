# Resources Monitor (Plasma 6 widget)

Plasmoid for monitoring CPU, memory, network traffic, GPUs, disks and batteries.

- **Charts and text items:** CPU (usage, clock, temperature), memory (physical or application, swap, and an optional separate cache band), GPU, network, disk I/O, battery and custom text.
- **Configurable layout:** graphs can be added, removed, reordered and repeated, and each one has its own colours, sizes and warning thresholds.
- **No external processes for data:** all values come from KDE's system statistics service (ksystemstats). The only external command is `kstart`, which opens the chosen application when the widget is clicked.

## Requirements

Plasma 6, ksystemstats and libksysguard (installed with Plasma), and KDE QuickCharts.

## Install

User install:

```sh
kpackagetool6 -t Plasma/Applet --install package
```

System-wide install (for packaging, use `DESTDIR`):

```sh
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build
```
