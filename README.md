# R9-EQ

**A native macOS system-wide equalizer that lives in the notch.**

R9-EQ is a 10-band system-wide audio equalizer for macOS with a notch-integrated
interface that drops down like a native Apple control. It processes **all** of
your Mac's audio in real time using Apple's own Core Audio process-tap APIs — no
kernel extensions, no third-party audio router in the signal path — and adds a
one-of-a-kind **Virtual Driver Configuration** studio for designing and auditioning
hybrid IEM/headphone driver stacks.

> Created by **Rhineul Islam** · `com.rhine.EQ` · v0.3.1

**Install — paste this into Terminal** (no security warnings, any Mac, macOS 14.4+):

```bash
curl -fsSL https://raw.githubusercontent.com/XPro-Gamer-Rhine/R9-EQ-app/main/install.sh | bash
```

*(or [⬇︎ download the DMG](../../releases/latest) — see [Install](#install) for the extra steps it needs)*

---

## Showcase

**System-wide 10-band EQ, dropping down from the notch (Liquid Glass theme):**

![R9-EQ — Liquid Glass, system-wide](docs/images/eq-liquid-glass.png)

**Per-app mode on the true-black System Default theme (OLED-friendly):**

![R9-EQ — System Default dark, per-app](docs/images/eq-dark.png)

**Virtual Driver Configuration — build a virtual IEM from stacked driver technologies:**

![Virtual Driver Configuration — builder](docs/images/vdc-builder.png)

**Per-driver tuning with a live signature preview:**

![Virtual Driver Configuration — tuning](docs/images/vdc-tuning.png)

### Themes

Every theme applies to **both** the notch panel and the VDC window.

| Liquid Glass | Frosted Glass |
|---|---|
| ![Liquid Glass](docs/images/panel-liquid-glass.png) | ![Frosted Glass](docs/images/panel-frosted.png) |

| System Default (OLED black) | Cyberhax |
|---|---|
| ![System Default](docs/images/panel-system-default.png) | ![Cyberhax](docs/images/panel-cyberhax.png) |

---

## Features

### Equalizer
- **10-band graphic EQ** (32 Hz → 16 kHz), ±12 dB per band, with a global preamp.
- **Real-time, system-wide** — equalizes every app's output at once (browser,
  Music, Spotify, games, calls).
- **Response-curve editor** — drag the live frequency curve directly, or use the
  vertical band sliders.
- **Presets** — Flat, Bass Boost, Vocal, Treble, V-Shaped, Podcast, plus a
  **Genre menu** (Rock, Pop, Hip-Hop, EDM, R&B, Jazz, Classical, Metal, Acoustic,
  Lo-Fi) and an **IEM menu** with tunings inspired by high-end in-ear monitors
  (Harman IEM Target, IER-Z1R, IE 900, Blessing 3, U12t, Andromeda). The active
  preset is highlighted; any manual edit marks the curve as custom.
- **Profiles** — save, name, switch, import and export your own EQ profiles.
- **Per-app EQ** — System-wide mode, or Per-App mode that auto-loads a saved curve
  whenever a given app comes to the foreground.

### Virtual Driver Configuration (VDC)
A studio for building a "virtual IEM" out of stacked driver technologies (Dynamic,
Balanced Armature, Electrostatic, Planar Magnetic, MEMS, Piezoelectric, Bone
Conduction). Driver voicings and stacking rules are grounded in published IEM
engineering research.
- **Drag-and-drop driver stacking** with authentic, per-kind frequency envelopes.
- **Per-driver tuning** — Level, Center, Focus, Depth and Resonance per instance.
  Adding multiples of the same driver auto-staggers their voicing (the way real
  manufacturers bin and tune duplicate drivers).
- **Depth modelling** — front/rear driver placement shaped like physical stacks.
- **Live preview** — apply the virtual driver to the real EQ and listen.
- **IEM Library — load a real IEM** — search 1,000+ real in-ear monitors (data
  derived from crinacle.com's IEM Ranking List) and rebuild any model's actual
  driver setup with one click, voiced by its published sound signature and
  technical grade. Fully editable afterwards.
- **First-open tour** — the studio walks you through itself the first time you
  open it (replayable from the ? menu).
- **Export** — a full PDF report (colored per-driver curves + combined response +
  tuning table) and CSV data. **Import/export the whole configuration** as JSON so
  you can share builds with others.

### Onboarding
- **First-run tutorial** — on first launch R9-EQ opens itself and spotlights each
  control (power, sliders, presets, profiles, per-app mode, VDC, themes) so new
  users always find it. Replay anytime: theme menu → Help → Show Tutorial.
- **Double-click re-opens** — opening the app again in Finder/Dock brings out the
  panel.

### Design & system integration
- **Menu-bar mode (default)** — an **R9 menu-bar icon** appears in your menu bar
  on every Mac; click it to open or close the panel, which floats just below the
  bar as a fully-rounded popover. It's the default because it's easy to find on
  any machine (and it's the only sensible affordance on Macs without a notch —
  Mac mini, iMac, Studio displays, pre-notch MacBooks).
- **Notch drop-down (opt-in on notch MacBooks)** — turn off *Menu-Bar Mode*
  (Theme menu → **Layout**) and the panel pours down out of the notch instead,
  with a fast, smooth Apple-style spring (a GPU layer-mask reveal — the content is
  laid out once and never re-flows, so there's no jank), rounded bottom corners
  matching the notch radius, and opens on hover / closes when the pointer leaves.
- **Four themes**, applied to both the notch panel and the VDC window:
  - **Liquid Glass** — translucent glossy glass.
  - **Frosted Glass** — heavier matte frost.
  - **System Default** — follows macOS appearance (true-black/OLED in Dark Mode,
    native light surface in Light Mode).
  - **Cyberhax** — the "Lucid" cyberpunk palette (red/blue/green neon, near-black
    base), inspired by [cybrcore/cybrdots](https://github.com/cybrcore/cybrdots).
- **Now-playing media bar** — shows the current track (Music / Spotify / browser)
  with transport controls.
- **Record the EQ'd output** — mirror processed audio to *BlackHole 16ch* so screen
  recorders can capture the equalized sound.

---

## How it works

R9-EQ does **not** put BlackHole in your output path. It uses Apple's modern
Core Audio process-tap stack (macOS 14.4+):

1. A **system audio process tap** captures every other process's output.
2. A **private aggregate device** wraps that tap together with your real output
   device, with tap auto-start enabled.
3. A raw **`AudioDeviceIOProc`** runs the DSP on the audio thread and writes the
   processed signal straight back to the hardware — unity gain, no volume loss.
4. The DSP core is **10 RBJ peaking biquads per channel** (Direct-Form-I
   transposed), with coefficients recomputed lock-free from an atomic parameter
   snapshot, and NaN/Inf self-healing so a transient can never latch the filter
   into digital silence.

This is why R9-EQ is loud (no halving of volume), low-latency, and reliable from
the first click — and why it needs the **System Audio Recording** permission.

---

## Requirements

- **macOS 14.4 or later** for the system-wide EQ (the process-tap engine).
- Apple Silicon or Intel Mac.
- Grants the **System Audio Recording** permission on first start.
- *BlackHole 16ch* is only needed for the optional "record the EQ'd output" mirror
  — not for normal equalization.

---

## Install

**Recommended — paste this one line into Terminal** (⌘-Space, type "Terminal"):

```bash
curl -fsSL https://raw.githubusercontent.com/XPro-Gamer-Rhine/R9-EQ-app/main/install.sh | bash
```

That downloads the latest release, installs it into Applications, and launches
it — **no security warnings, nothing blocked, works on every Mac** (Apple Silicon
and Intel, macOS 14.4+). Then:

1. Approve the **System Audio Recording** prompt (System Settings → Privacy &
   Security → System Audio Recording). Required — without it the EQ is silent.
2. Click the **R9 menu-bar icon** (top-right) and press the power button.

<details>
<summary><strong>Why Terminal? And how to install from the DMG instead</strong></summary>

R9-EQ is free and ad-hoc signed — there is no paid Apple Developer account behind
it, so it isn't notarized. When a **browser** downloads it, macOS quarantines it,
and on **macOS 15 Sequoia / 26 Tahoe** double-clicking the `.app` runs a throwaway
copy that shows only the Mic prompt and then **moves R9-EQ to the Trash** — an
Apple security policy, not an app bug. A `curl` download carries no quarantine
flag, so the Terminal installer never meets Gatekeeper at all. That's why it's
the recommended path.

**From the DMG instead:** download **`R9-EQ.dmg`** from the
[latest release](../../releases/latest), open it, and double-click
**`Double-click to install R9-EQ.command`** (click **Open** when Terminal asks).
It installs R9-EQ into Applications, clears the quarantine flag, and launches it.

**GUI-only fallback:** drag R9-EQ to Applications, double-click it once (it gets
blocked), then System Settings → **Privacy & Security** → scroll down → **Open
Anyway** → **Open**.

</details>

---

## Usage

- **Open the panel** — click the **R9 menu-bar icon** (default). Click it again,
  or click away, to close.
- **Power** — top-left power button starts/stops the EQ.
- **Curve vs sliders** — toggle with the waveform icon.
- **Virtual Driver** — the cube icon opens the VDC studio.
- **Output device / Theme** — the headphones and palette menus on the right.
- **Layout** — Theme menu → **Layout → Menu-Bar Mode**. On a notch MacBook, turn
  it off to use the notch drop-down instead (hover the notch to open).

---

## Privacy

R9-EQ processes audio entirely **on-device**. It captures system audio only to
equalize it in real time; nothing is recorded, stored, or transmitted unless you
explicitly enable the *BlackHole 16ch* recording mirror. The now-playing readout
uses the local Media Remote info for the track title/artist only.

---

## Credits

- **Created by Rhineul Islam.**
- Cyberhax theme palette: the "Lucid" scheme from
  [cybrcore/cybrdots](https://github.com/cybrcore/cybrdots) /
  [cybrcore/cybrcolors](https://github.com/cybrcore/cybrcolors).
- Optional recording mirror uses [BlackHole](https://github.com/ExistentialAudio/BlackHole).

---

## License

© 2026 Rhineul Islam. All rights reserved.

> This repository hosts the public release (app download + documentation) only.
> The R9-EQ source code is closed.
