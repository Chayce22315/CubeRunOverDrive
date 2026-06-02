# Cube Run: OVERDRIVE

2D arcade chaos runner in **SpriteKit / Swift 6** — **Phase 1** core gameplay + **Phase 2** chaos systems.

## Requirements

- **Xcode 26.3** (or newer)
- **iOS 17+** iPhone (physical device or Simulator)
- Apple ID for code signing

## Run on a real iPhone

1. Copy this repo to your Mac.
2. Open `CubeRunOverDrive/CubeRunOverDrive.xcodeproj`.
3. Select the **CubeRunOverDrive** scheme.
4. **Signing & Capabilities** → set your **Team** (Personal Team works for device testing).
5. Connect your iPhone via USB (or use wireless debugging).
6. Choose your **iPhone** as the run destination (not Simulator).
7. Press **Run** (⌘R). Trust the developer certificate on the device if prompted.

The scene uses your device’s full screen and safe areas (`GameLayout` + `viewDidLayoutSubviews`).

## Run in Simulator

Same steps, but pick an **iPhone** simulator as the destination.

## Controls

| Input | Action |
|--------|--------|
| Tap (start / restart) | Begin run or restart after death |
| Tap (while playing) | Jump |
| Hold ~0.12s or drag | Dive |
| **KICK** (bottom-right, air only) | Drop kick — can detonate nearby obstacles |
| **SAFE FX** toggle (top area) | Photosensitive-safe mode (reduced flash / shake) |

## Phase 2 features

- **Explosions** — particle bursts when cars hit blocks or kick detonates obstacles
- **Chain reactions** — nearby obstacles explode in sequence (depth-capped)
- **Traffic density** — spawns get faster and more cars appear as score rises (`CHAOS xN` HUD)
- **Impact frames** — screen shake + brief flash (disabled/reduced in SAFE FX mode)
- **Photosensitive toggle** — `SAFE FX: ON/OFF` on the start screen (persists via UserDefaults)

## Phase 2 test checklist

- [ ] Cars colliding with blocks trigger explosions and chains
- [ ] Drop kick destroys a nearby obstacle without killing the player
- [ ] Score increases → spawn rate increases and **CHAOS xN** appears
- [ ] Hits and explosions trigger shake/flash (OFF when SAFE FX is ON)
- [ ] SAFE FX toggle works and persists after relaunch
- [ ] Stable on physical device at ~60 FPS

## Build an IPA for Sideloadly (command line, Mac only)

From the **repo root** on your Mac:

```bash
chmod +x scripts/build-ipa-sideloadly.sh

# Recommended: unsigned IPA — Sideloadly signs when you install
./scripts/build-ipa-sideloadly.sh
```

Output: `build/sideloadly/CubeRunOverDrive.ipa`

**Optional:** pass your 10-character Team ID to export a pre-signed development IPA:

```bash
./scripts/build-ipa-sideloadly.sh AB12CD34EF
```

### Install with Sideloadly

1. Install [Sideloadly](https://sideloadly.io/) on your Mac or Windows PC.
2. Connect your iPhone (USB) and unlock it.
3. Drag `build/sideloadly/CubeRunOverDrive.ipa` into Sideloadly.
4. Enter your **Apple ID** (free account is fine).
5. Click **Start** and trust the developer profile on the iPhone if asked.

Apps signed this way typically expire after **7 days**; rebuild the IPA and sideload again to refresh.

## Phase lock

**Phases 3–8** (bombs, void, multiplayer, shop, achievements, replay) are **not** implemented. Approve before starting Phase 3.

## Project layout

```text
CubeRunOverDrive/
├── CubeRunOverDrive.xcodeproj
└── CubeRunOverDrive/
    ├── App/          (SceneDelegate, GameViewController)
    ├── Scenes/
    ├── Game/
    ├── Player/
    ├── Camera/
    ├── World/        (GameLayout, GroundNode)
    ├── Obstacles/
    ├── Chaos/        (Phase 2)
    ├── Settings/
    ├── UI/
    ├── Systems/
    └── Extensions/
```
