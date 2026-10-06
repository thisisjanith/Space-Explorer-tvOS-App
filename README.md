# Space Explorer — tvOS App

Space Explorer is an interactive solar system app for **Apple TV**. Users explore the eight planets with the Siri Remote: they view facts and statistics, watch planets spin with their moons and rings, and take a Space Quiz alone or with a second player.

Built with **Swift** and **SwiftUI**. There are no third-party dependencies, network calls or image assets: all planets and animations are drawn in code.

---

## Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Build and run in Xcode](#build-and-run-in-xcode)
4. [Build and run from the command line](#build-and-run-from-the-command-line)
5. [Using the app (Siri Remote controls)](#using-the-app-siri-remote-controls)
6. [Project structure](#project-structure)
7. [Architecture](#architecture)
8. [Code documentation](#code-documentation)
9. [Troubleshooting](#troubleshooting)
10. [Data sources](#data-sources)

---

## Features

| # | Screen | What it does |
|---|--------|--------------|
| 1 | **Home** | Animated starfield with shooting stars, spinning Saturn and Earth, **Start** and **Space Quiz** buttons. |
| 2 | **Solar System** | Animated orbit diagram of all 8 planets around the Sun, plus a row of planet cards. The focused planet is enlarged, glows, and its orbit is highlighted. |
| 3 | **Planet Details** | One reusable screen for every planet: distance from the Sun, diameter, temperature, moons, day length and year length. |
| 4 | **Planet Exploration** | Large rotating planet with orbiting moons. Venus and Uranus spin backwards, Uranus is tilted on its side, Saturn's rings turn. |
| 5 | **Did You Know?** | Three facts per planet with slide animations and page dots. |
| 6 | **Space Quiz** | 10 random questions (from a bank of 14) with shuffled answers, instant feedback with explanations, and a final score with a star rating. |

**Two-player mode:** two players share one remote and take turns answering. Scores are shown live and a winner is announced at the end.

---

## Requirements

| Requirement | Version |
|-------------|---------|
| Mac | macOS that supports Xcode 26 |
| Xcode | **26.5 or later** (includes the tvOS 26.5 SDK) |
| Deployment target | **tvOS 26.5** |
| Device | Apple TV simulator (recommended: *Apple TV 4K (3rd generation)*) or a real Apple TV running tvOS 26.5+ |
| Disk space | **At least 10 GB free**. The tvOS simulator needs several GB when it boots. |

No packages, CocoaPods or API keys are needed.

---

## Build and run in Xcode

1. **Open the project.** Double-click `Janith-TVOS.xcodeproj`, or run:
   ```bash
   open Janith-TVOS.xcodeproj
   ```
2. **Select the scheme.** In the toolbar, make sure the scheme is **Janith-TVOS**.
3. **Select a destination.** Click the device menu next to the scheme and choose **Apple TV 4K (3rd generation)** under *tvOS Simulators*.
   - If no Apple TV simulator is listed, open **Xcode ▸ Settings ▸ Components** and download the **tvOS** platform.
4. **Build and run.** Press **⌘R** (or click ▶). The simulator opens and the app launches on the Home screen.
5. **Control the app.** Use the on-screen remote (**Window ▸ Show Apple TV Remote** in the Simulator) or your keyboard. See [the controls below](#using-the-app-siri-remote-controls).

### Running on a real Apple TV

1. Pair the Apple TV with Xcode: **Window ▸ Devices and Simulators ▸ Devices** (the Apple TV must be on the same network, under *Settings ▸ Remotes and Devices ▸ Remote App and Devices*).
2. Select the **Janith-TVOS** target ▸ **Signing & Capabilities**, and set **Team** to your own Apple developer team. You may also need to change the **Bundle Identifier** to something unique.
3. Choose the Apple TV as the destination and press **⌘R**.

---

## Build and run from the command line

From the folder that contains `Janith-TVOS.xcodeproj`:

```bash
# 1. Build for the tvOS Simulator
xcodebuild \
  -project Janith-TVOS.xcodeproj \
  -scheme Janith-TVOS \
  -destination 'platform=tvOS Simulator,name=Apple TV 4K (3rd generation)' \
  -derivedDataPath build \
  build

# 2. Boot the simulator and open the Simulator app
xcrun simctl boot "Apple TV 4K (3rd generation)"
open -a Simulator

# 3. Install and launch the app
xcrun simctl install booted build/Build/Products/Debug-appletvsimulator/Janith-TVOS.app
xcrun simctl launch booted Janith-Kavinda.Janith-TVOS
```

To list the Apple TV simulators installed on your Mac:

```bash
xcrun simctl list devices available | grep -i "apple tv"
```

---

## Using the app (Siri Remote controls)

| Siri Remote | Simulator keyboard | Action |
|-------------|--------------------|--------|
| Swipe / press left, right, up, down | Arrow keys | Move focus between planets and buttons |
| Click (touch surface / centre) | Return | Select the focused planet or button |
| Menu / Back | Esc | Go back to the previous screen |
| Play/Pause | Use the on-screen remote | Pause or resume planet animations (Solar System, Planet Details and Exploration screens) |

The Exploration screen also has an on-screen **Pause/Play** button.

### Suggested demo path

```
Home ─► Start ─► Solar System ─► (swipe to Earth, click) ─► Planet Details
     ─► Explore Planet ─► Facts ─► Next Fact ─► Space Quiz ─► 1 or 2 Players
     ─► answer 10 questions ─► Final Score ─► Solar System
```

---

## Project structure

```
Janith-TVOS/
├── README.md                         ← this file
├── Space_Explorer_tvOS_App_Plan.md   ← original design plan
├── Janith-TVOS.xcodeproj             ← Xcode project
├── Janith-TVOS/                      ← app source code
│   ├── Janith_TVOSApp.swift          ← @main app entry point
│   ├── ContentView.swift             ← root NavigationStack and screen routing
│   ├── Models/
│   │   ├── Planet.swift              ← Planet model + appearance types
│   │   ├── PlanetData.swift          ← data for all 8 planets
│   │   ├── QuizQuestion.swift        ← question model + question bank
│   │   ├── QuizGame.swift            ← quiz rules and scoring
│   │   └── AppRouter.swift           ← navigation routes
│   ├── Views/
│   │   ├── HomeView.swift            ← Screen 1: Welcome
│   │   ├── SolarSystemView.swift     ← Screen 2: Solar system + planet selection
│   │   ├── PlanetDetailView.swift    ← Screen 3: Planet information
│   │   ├── PlanetAnimationView.swift ← Screen 4: Planet exploration
│   │   ├── FactsView.swift           ← Screen 5: Did You Know?
│   │   ├── QuizView.swift            ← Screen 6: Quiz setup + questions
│   │   └── QuizResultView.swift      ← Quiz final score
│   ├── Components/
│   │   ├── PlanetView.swift          ← procedurally drawn rotating planet
│   │   ├── OrbitDiagram.swift        ← animated orbits around the Sun
│   │   ├── StarfieldBackground.swift ← twinkling stars + shooting stars
│   │   ├── PlanetCard.swift          ← focusable planet tile
│   │   ├── SpaceButton.swift         ← standard focusable button
│   │   ├── StatTile.swift            ← statistic tile
│   │   ├── PausableTimeline.swift    ← pause/resume-able animation clock
│   │   └── Theme.swift               ← colours and fonts
│   └── Assets.xcassets               ← layered app icon, Top Shelf images, accent colour
├── Tools/
│   └── make_icons.swift              ← script that renders the logo, app icon and Top Shelf images
├── Janith-TVOSTests/                 ← unit test target
└── Janith-TVOSUITests/               ← UI test target
```

The Xcode project uses **folder-synced groups**, so any `.swift` file added inside `Janith-TVOS/` is compiled automatically. You don't need to add it to the project by hand.

---

## Architecture

### Data-driven, reusable screens
All planet content lives in one model, `Planet` (`Models/Planet.swift`), with the eight instances in `Models/PlanetData.swift`. The Planet Details, Exploration and Facts screens each take a `Planet`, so **one view serves all eight planets**. Adding or editing a planet only changes data, never UI code.

### Navigation
`ContentView` hosts a SwiftUI `NavigationStack` whose path is owned by `AppRouter`, an `@Observable` class shared through the environment. Each screen is a `Route` case. Screens call `router.push(_:)`, `router.pop()` or `router.popToSolarSystem()`. The Siri Remote's **Menu** button pops the stack automatically.

### Quiz logic
`QuizGame` (`Models/QuizGame.swift`) holds all quiz state and rules: question selection, answer selection, submission, scoring, turn-taking and phases. The quiz views only display that state and forward button presses. This keeps the rules in one testable place.

### Siri Remote and focus
- tvOS's **focus engine** handles directional movement. Custom `ButtonStyle`s read `@Environment(\.isFocused)` to draw a clear focus state: scale-up, glow and colour change.
- `@FocusState` and `.defaultFocus` set the starting focus (Earth on the Solar System screen) and move focus in code. For example, after you pick a quiz answer, focus jumps to **Submit**.
- `.onPlayPauseCommand` connects the remote's Play/Pause button to the animations.

### Rendering and animation
- Planets are drawn with SwiftUI `Canvas`. Surface features (continents, storms, craters, clouds) are stored as latitude and longitude, then **projected onto a sphere** every frame. As the longitude changes, features move across the disc and shrink and fade at the edge, which gives a convincing 3D spin without a 3D engine.
- Rings and moons are drawn in two halves (behind and in front of the planet) so they pass correctly behind it.
- Procedural details use a **seeded random generator** (`SeededGenerator`), so planets look the same on every launch.
- `PausableTimeline` wraps `TimelineView` so animations can pause and resume without jumping ahead.
- Spin speeds are based on each planet's real rotation period, compressed on a log scale so slow planets like Venus still visibly move.

### App icon and logo
The logo is a blue-purple ringed planet with a moon and sparkles on a starfield, in the same colours as the app. It is drawn in code by `Tools/make_icons.swift`, which writes every image in the asset catalog:

| Asset | Size |
|-------|------|
| App Icon (layered: Back, Middle, Front) | 400×240 @1x, 800×480 @2x |
| App Icon – App Store (layered) | 1280×768 |
| Top Shelf Image | 1920×720 @1x, 3840×1440 @2x |
| Top Shelf Image Wide | 2320×720 @1x, 4640×1440 @2x |

The icon uses tvOS's layered parallax format. The starfield is the opaque **Back** layer. The planet and the far half of its ring are the **Middle** layer. The near half of the ring, the moon and the sparkles are the **Front** layer. When the icon is focused on the Apple TV home screen, the ring visibly floats in front of the planet.

To regenerate the images after changing the script:

```bash
swift Tools/make_icons.swift "Janith-TVOS/Assets.xcassets/App Icon & Top Shelf Image.brandassets"
```

### Concurrency
The project uses Swift's *default main-actor isolation*. Plain data types (`Planet`, `QuizQuestion`, …) are marked `nonisolated` and `Sendable` so they can be shared freely.

---

## Code documentation

All source files follow standard Swift documentation conventions:

- A **file header** says what the file is for and which screen it implements.
- **`///` doc comments** describe every type, important property and method, including `- Parameters:` sections where useful. In Xcode, **Option-click** any symbol to see its documentation.
- **`// MARK: -`** sections split longer files into parts, shown in Xcode's jump bar.
- **Inline `//` comments** explain non-obvious logic, such as the sphere projection, back/front drawing order and focus handling.
- **`#Preview`** blocks let each screen and component be viewed in Xcode's canvas without running the app. Open a file and press **⌥⌘↩** to show the canvas.

To build browsable HTML documentation from these comments, use **Product ▸ Build Documentation** in Xcode.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| *"No space left on device"* or the simulator won't boot | Free disk space. Delete `~/Library/Developer/Xcode/DerivedData`, and remove unusable simulators with `xcrun simctl delete unavailable`. |
| No Apple TV simulator in the destination list | **Xcode ▸ Settings ▸ Components** → download the tvOS platform. |
| *"Unable to find a destination matching…"* on the command line | Run `xcrun simctl list devices available` and use an Apple TV name from that list in `-destination`. |
| Signing error when running on a real Apple TV | Set your own **Team** (and a unique Bundle Identifier) under *Signing & Capabilities*. Signing is not needed for the simulator. |
| Previews don't load | Make sure the selected destination is a tvOS simulator, then press **⌥⌘P** to refresh the canvas. |

---

## Data sources

Planet statistics and facts come from NASA's public planetary fact sheets and the NASA Solar System Exploration website. Moon counts change as new moons are discovered. The values in `Models/PlanetData.swift` are Jupiter 95, Saturn 274, Uranus 29 and Neptune 16.
